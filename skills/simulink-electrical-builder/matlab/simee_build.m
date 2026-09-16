function report = simee_build(blueprintFile)
%SIMEE_BUILD Build a Simulink model from a JSON blueprint.
%
% This builder intentionally uses documented programmatic Simulink APIs and
% keeps source provenance in the blueprint. It can copy installed library
% blocks or coherent subsystems from locally available example models.
%
% Example:
%   report = simee_build('my_blueprint.json');
%
% The generated .slx is local to the user's MATLAB environment. Exact
% MathWorks library/example paths must be resolved for that installed release.

if nargin < 1 || isempty(blueprintFile)
    error('simee_build:MissingBlueprint', 'Provide a blueprint JSON file.');
end

bp = jsondecode(fileread(blueprintFile));
compat = simee_validate_blueprint(bp);
if ~compat.ok
    error('simee_build:CompatibilityFailed', 'Blueprint compatibility failed:\n- %s', strjoin(compat.errors, '\n- '));
end

for k = 1:numel(compat.warnings)
    warning('simee_build:CompatibilityWarning', '%s', compat.warnings{k});
end

env = simee_detect_environment();
modelName = char(bp.model_name);
if ~isvarname(modelName)
    error('simee_build:InvalidModelName', 'model_name must be a valid MATLAB/Simulink model name: %s', modelName);
end

outputDir = pwd;
if isfield(bp, 'output_dir') && ~isempty(bp.output_dir)
    outputDir = char(bp.output_dir);
end
if exist(outputDir, 'dir') ~= 7
    mkdir(outputDir);
end

if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

new_system(modelName);
cleanupObj = onCleanup(@() safeClose(modelName)); %#ok<NASGU>

applyModelConfiguration(modelName, bp);

mods = bp.modules;
resolved = repmat(struct('name', '', 'source', '', 'destination', ''), numel(mods), 1);
for k = 1:numel(mods)
    m = mods(k);
    destination = [modelName '/' char(m.name)];
    sourceType = lower(char(m.source_type));

    switch sourceType
        case {'empty_subsystem', 'placeholder'}
            source = 'built-in/Subsystem';
            add_block(source, destination);
        case {'library_block', 'model_block', 'example_subsystem'}
            source = char(m.source);
            loadSourceRoot(source);
            add_block(source, destination);
        otherwise
            error('simee_build:UnknownSourceType', 'Unknown source_type "%s" for module %s.', sourceType, char(m.name));
    end

    if isfield(m, 'position') && numel(m.position) == 4
        set_param(destination, 'Position', double(m.position(:)'));
    end

    if isfield(m, 'parameters') && ~isempty(m.parameters)
        applyParameters(destination, m.parameters);
    end

    if isfield(m, 'description') && ~isempty(m.description)
        try
            set_param(destination, 'Description', char(m.description));
        catch
            % Some block types do not expose Description as a settable field.
        end
    end

    resolved(k).name = char(m.name);
    if exist('source', 'var')
        resolved(k).source = source;
    end
    resolved(k).destination = destination;
end

if isfield(bp, 'connections') && ~isempty(bp.connections)
    conns = bp.connections;
    for k = 1:numel(conns)
        connectOne(modelName, conns(k));
    end
end

compileOk = false;
compileMessage = '';
try
    set_param(modelName, 'SimulationCommand', 'update');
    compileOk = true;
catch ME
    compileMessage = ME.message;
end

simulationOk = [];
simulationMessage = '';
if isfield(bp, 'simulate_after_build') && logical(bp.simulate_after_build)
    if ~compileOk
        simulationOk = false;
        simulationMessage = 'Simulation skipped because model update/compile failed.';
    else
        try
            sim(modelName);
            simulationOk = true;
        catch ME
            simulationOk = false;
            simulationMessage = ME.message;
        end
    end
end

outputFile = fullfile(outputDir, [modelName '.slx']);
save_system(modelName, outputFile);

report = struct();
report.model_name = modelName;
report.model_file = outputFile;
report.blueprint_file = char(blueprintFile);
report.environment = env;
report.compatibility = compat;
report.resolved_modules = resolved;
report.compile_ok = compileOk;
report.compile_message = compileMessage;
report.simulation_ok = simulationOk;
report.simulation_message = simulationMessage;
report.generated_at = datestr(now, 31);

writeModelReport(outputDir, report);

if isfield(bp, 'open_after_build') && logical(bp.open_after_build)
    open_system(modelName);
end

fprintf('Generated model: %s\n', outputFile);
if compileOk
    fprintf('Model update/compile: PASS\n');
else
    fprintf('Model update/compile: FAIL\n%s\n', compileMessage);
end
end

function applyModelConfiguration(modelName, bp)
if isfield(bp, 'stop_time') && ~isempty(bp.stop_time)
    set_param(modelName, 'StopTime', valueToString(bp.stop_time));
end

if isfield(bp, 'solver') && ~isempty(bp.solver)
    s = bp.solver;
    if isfield(s, 'type') && ~isempty(s.type)
        set_param(modelName, 'SolverType', char(s.type));
    end
    if isfield(s, 'name') && ~isempty(s.name)
        set_param(modelName, 'Solver', char(s.name));
    end
    if isfield(s, 'fixed_step') && ~isempty(s.fixed_step)
        set_param(modelName, 'FixedStep', valueToString(s.fixed_step));
    end
    if isfield(s, 'max_step') && ~isempty(s.max_step)
        set_param(modelName, 'MaxStep', valueToString(s.max_step));
    end
end
end

function loadSourceRoot(source)
slashIdx = find(source == '/', 1, 'first');
if isempty(slashIdx)
    root = source;
else
    root = source(1:slashIdx-1);
end
try
    load_system(root);
catch ME
    error('simee_build:SourceUnavailable', 'Cannot load source root "%s" for "%s": %s', root, source, ME.message);
end
end

function applyParameters(blockPath, p)
fields = fieldnames(p);
for i = 1:numel(fields)
    key = fields{i};
    value = p.(key);
    try
        set_param(blockPath, key, valueToString(value));
    catch ME
        error('simee_build:ParameterFailed', 'Failed to set %s.%s: %s', blockPath, key, ME.message);
    end
end
end

function connectOne(modelName, c)
systemPath = modelName;
if isfield(c, 'system') && ~isempty(c.system)
    rel = char(c.system);
    if strcmp(rel, modelName) || startsWith(rel, [modelName '/'])
        systemPath = rel;
    else
        systemPath = [modelName '/' rel];
    end
end

mode = 'signal';
if isfield(c, 'mode') && ~isempty(c.mode)
    mode = lower(char(c.mode));
end

switch mode
    case {'signal', 'path'}
        if ~isfield(c, 'source') || ~isfield(c, 'destination')
            error('simee_build:ConnectionMissingEndpoint', 'Signal connection requires source and destination, e.g. "A/1" -> "B/1".');
        end
        add_line(systemPath, char(c.source), char(c.destination), 'autorouting', 'on');

    case {'port_handle', 'physical'}
        required = {'source_block','source_port_type','source_port_index', ...
                    'destination_block','destination_port_type','destination_port_index'};
        for i = 1:numel(required)
            if ~isfield(c, required{i})
                error('simee_build:ConnectionMissingField', 'Port-handle connection missing field %s.', required{i});
            end
        end
        srcBlock = qualifyBlock(modelName, char(c.source_block));
        dstBlock = qualifyBlock(modelName, char(c.destination_block));
        srcH = resolvePortHandle(srcBlock, char(c.source_port_type), double(c.source_port_index));
        dstH = resolvePortHandle(dstBlock, char(c.destination_port_type), double(c.destination_port_index));
        add_line(systemPath, srcH, dstH, 'autorouting', 'on');

    otherwise
        error('simee_build:UnknownConnectionMode', 'Unknown connection mode: %s', mode);
end
end

function blockPath = qualifyBlock(modelName, b)
if strcmp(b, modelName) || startsWith(b, [modelName '/'])
    blockPath = b;
else
    blockPath = [modelName '/' b];
end
end

function h = resolvePortHandle(blockPath, portType, index)
ph = get_param(blockPath, 'PortHandles');
fields = fieldnames(ph);
match = find(strcmpi(fields, portType), 1, 'first');
if isempty(match)
    error('simee_build:PortTypeNotFound', 'Block %s has no port-handle field named %s. Available: %s', blockPath, portType, strjoin(fields, ', '));
end
arr = ph.(fields{match});
if index < 1 || index > numel(arr)
    error('simee_build:PortIndexOutOfRange', 'Block %s port type %s has %d ports; requested %d.', blockPath, fields{match}, numel(arr), index);
end
h = arr(index);
end

function s = valueToString(v)
if ischar(v)
    s = v;
elseif isstring(v) && isscalar(v)
    s = char(v);
elseif isnumeric(v) || islogical(v)
    if isscalar(v)
        s = num2str(v, 16);
    else
        s = mat2str(v, 16);
    end
else
    error('simee_build:UnsupportedParameterValue', 'Unsupported parameter value type: %s', class(v));
end
end

function writeModelReport(outputDir, report)
path = fullfile(outputDir, [report.model_name '_MODEL_REPORT.md']);
fid = fopen(path, 'w');
if fid < 0
    warning('simee_build:ReportWriteFailed', 'Could not write model report: %s', path);
    return;
end
cleanupFid = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, '# Model Report — %s\n\n', report.model_name);
fprintf(fid, '- Generated: `%s`\n', report.generated_at);
fprintf(fid, '- MATLAB release: `%s`\n', report.environment.matlab_release);
fprintf(fid, '- Recommended backend: `%s`\n', report.environment.recommended_backend);
fprintf(fid, '- Blueprint: `%s`\n', report.blueprint_file);
fprintf(fid, '- Model file: `%s`\n', report.model_file);
fprintf(fid, '- Update/compile: **%s**\n', passFail(report.compile_ok));
if ~isempty(report.simulation_ok)
    fprintf(fid, '- Simulation: **%s**\n', passFail(report.simulation_ok));
end

fprintf(fid, '\n## Modules\n\n');
fprintf(fid, '| Module | Source | Destination |\n| --- | --- | --- |\n');
for k = 1:numel(report.resolved_modules)
    r = report.resolved_modules(k);
    fprintf(fid, '| `%s` | `%s` | `%s` |\n', r.name, r.source, r.destination);
end

fprintf(fid, '\n## Compatibility warnings\n\n');
if isempty(report.compatibility.warnings)
    fprintf(fid, 'None from static blueprint validation.\n');
else
    for k = 1:numel(report.compatibility.warnings)
        fprintf(fid, '- %s\n', report.compatibility.warnings{k});
    end
end

if ~report.compile_ok
    fprintf(fid, '\n## Compile/update failure\n\n```text\n%s\n```\n', report.compile_message);
end
if ~isempty(report.simulation_ok) && ~report.simulation_ok
    fprintf(fid, '\n## Simulation failure\n\n```text\n%s\n```\n', report.simulation_message);
end
end

function s = passFail(tf)
if tf
    s = 'PASS';
else
    s = 'FAIL';
end
end

function safeClose(modelName)
try
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
catch
end
end

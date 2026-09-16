function report = simee_validate_blueprint(bp)
%SIMEE_VALIDATE_BLUEPRINT Static compatibility checks for a model blueprint.
%
% report.ok       logical
% report.errors   cell array of blocking compatibility errors
% report.warnings cell array of non-blocking issues that require review

report = struct('ok', true, 'errors', {{}}, 'warnings', {{}});

if ~isfield(bp, 'model_name') || isempty(bp.model_name)
    report.errors{end+1} = 'Blueprint requires model_name.';
end

if ~isfield(bp, 'modules')
    report.errors{end+1} = 'Blueprint requires modules.';
    report.ok = false;
    return;
end

mods = bp.modules;
if isempty(mods)
    report.warnings{end+1} = 'Blueprint contains no modules.';
    report.ok = isempty(report.errors);
    return;
end

% One connected physical electrical network should use one backend.
backends = {};
for k = 1:numel(mods)
    if isfield(mods(k), 'backend') && ~isempty(mods(k).backend)
        b = char(mods(k).backend);
        if ~strcmpi(b, 'simulink-control-only') && ~strcmpi(b, 'none')
            backends{end+1} = lower(b); %#ok<AGROW>
        end
    end
end
backends = unique(backends);
if numel(backends) > 1
    report.errors{end+1} = sprintf('Multiple physical-network backends detected: %s. Separate them or define an explicit signal-level interface.', strjoin(backends, ', '));
end

% Nominal frequency consistency.
freqs = [];
for k = 1:numel(mods)
    if isfield(mods(k), 'nominal_frequency_hz') && ~isempty(mods(k).nominal_frequency_hz)
        freqs(end+1) = double(mods(k).nominal_frequency_hz); %#ok<AGROW>
    end
end
if ~isempty(freqs) && (max(freqs) - min(freqs) > 1e-9)
    report.errors{end+1} = sprintf('Nominal frequency mismatch across modules: %s Hz.', mat2str(unique(freqs)));
end

% Representation consistency for physical plant modules.
reprs = {};
for k = 1:numel(mods)
    if isfield(mods(k), 'representation') && ~isempty(mods(k).representation)
        r = lower(char(mods(k).representation));
        if ~strcmp(r, 'control') && ~strcmp(r, 'measurement')
            reprs{end+1} = r; %#ok<AGROW>
        end
    end
end
reprs = unique(reprs);
if any(strcmp(reprs, 'phasor')) && any(strcmp(reprs, 'emt'))
    report.errors{end+1} = 'Phasor and EMT plant representations are mixed without an explicit interface.';
end

% Unit system and PU-base checks.
unitSystems = {};
for k = 1:numel(mods)
    if isfield(mods(k), 'unit_system') && ~isempty(mods(k).unit_system)
        unitSystems{end+1} = lower(char(mods(k).unit_system)); %#ok<AGROW>
    end
end
if numel(unique(unitSystems)) > 1
    report.warnings{end+1} = 'Mixed SI/per-unit modules detected. Confirm explicit base conversions at every interface.';
end

for k = 1:numel(mods)
    if isfield(mods(k), 'unit_system') && strcmpi(char(mods(k).unit_system), 'pu')
        hasS = isfield(mods(k), 'base_power_va') && ~isempty(mods(k).base_power_va);
        hasV = isfield(mods(k), 'base_voltage_v') && ~isempty(mods(k).base_voltage_v);
        if ~(hasS && hasV)
            name = moduleName(mods(k), k);
            report.warnings{end+1} = sprintf('Per-unit module %s does not declare both base_power_va and base_voltage_v.', name);
        end
    end
end

% Discrete sample times should be equal or integer-related.
ts = [];
for k = 1:numel(mods)
    if isfield(mods(k), 'sample_time_s') && ~isempty(mods(k).sample_time_s)
        x = double(mods(k).sample_time_s);
        if isfinite(x) && x > 0
            ts(end+1) = x; %#ok<AGROW>
        end
    end
end
if numel(ts) > 1
    baseTs = min(ts);
    ratios = ts / baseTs;
    if any(abs(ratios - round(ratios)) > 1e-9)
        report.warnings{end+1} = sprintf('Controller sample times are not integer multiples of the fastest declared rate: %s s. Add/verify rate transitions.', mat2str(unique(ts)));
    end
end

% Require source information for non-placeholder build modules.
for k = 1:numel(mods)
    if ~isfield(mods(k), 'source_type') || isempty(mods(k).source_type)
        report.errors{end+1} = sprintf('Module %s has no source_type.', moduleName(mods(k), k));
        continue;
    end
    st = lower(char(mods(k).source_type));
    if ~strcmp(st, 'empty_subsystem') && ~strcmp(st, 'placeholder')
        if ~isfield(mods(k), 'source') || isempty(mods(k).source)
            report.errors{end+1} = sprintf('Module %s uses source_type=%s but has no source path.', moduleName(mods(k), k), st);
        end
    end
end

report.ok = isempty(report.errors);
end

function n = moduleName(m, idx)
if isfield(m, 'name') && ~isempty(m.name)
    n = char(m.name);
else
    n = sprintf('#%d', idx);
end
end

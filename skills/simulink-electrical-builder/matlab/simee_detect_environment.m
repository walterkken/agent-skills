function env = simee_detect_environment()
%SIMEE_DETECT_ENVIRONMENT Inspect MATLAB/Simulink electrical modeling environment.
%
% Returns a struct used by Simulink Electrical Builder to decide whether
% Simscape Electrical native blocks, legacy Specialized Power Systems, and
% migration helpers are available.
%
% Compatible with MATLAB R2021b-style syntax.

v = ver;
releaseName = version('-release');
productNames = {v.Name};

env = struct();
env.matlab_release = releaseName;
env.matlab_version = version;
env.products = productNames;
env.has_simulink = hasProduct(productNames, 'Simulink');
env.has_simscape = hasProduct(productNames, 'Simscape');
env.has_simscape_electrical = hasProduct(productNames, 'Simscape Electrical');
env.has_stateflow = hasProduct(productNames, 'Stateflow');
env.has_control_system_toolbox = hasProduct(productNames, 'Control System Toolbox');
env.has_simulink_control_design = hasProduct(productNames, 'Simulink Control Design');

env.has_powerlib = false;
try
    env.has_powerlib = ~isempty(which('powerlib'));
    if ~env.has_powerlib
        load_system('powerlib');
        env.has_powerlib = true;
        close_system('powerlib', 0);
    end
catch
    env.has_powerlib = false;
end

env.has_sps_conversion_assistant = exist('spsConversionAssistant', 'file') == 2;
env.release_at_or_after_r2026a = releaseAtOrAfter(releaseName, 'R2026a');

if env.release_at_or_after_r2026a
    env.recommended_backend = 'simscape-electrical-native';
    env.backend_reason = 'R2026a+ does not provide the legacy Specialized Power Systems library.';
elseif env.has_simscape_electrical
    env.recommended_backend = 'simscape-electrical-native';
    env.backend_reason = 'Simscape Electrical is installed; prefer the native backend for new reusable models.';
elseif env.has_powerlib
    env.recommended_backend = 'specialized-power-systems';
    env.backend_reason = 'Legacy powerlib is available while Simscape Electrical was not detected.';
else
    env.recommended_backend = 'simulink-control-only';
    env.backend_reason = 'No supported electrical physical-network backend was detected.';
end

fprintf('MATLAB release: %s\n', env.matlab_release);
fprintf('Simulink: %d | Simscape: %d | Simscape Electrical: %d | legacy powerlib: %d\n', ...
    env.has_simulink, env.has_simscape, env.has_simscape_electrical, env.has_powerlib);
fprintf('Recommended backend: %s\n', env.recommended_backend);
fprintf('Reason: %s\n', env.backend_reason);
end

function tf = hasProduct(names, target)
tf = any(strcmpi(names, target));
end

function tf = releaseAtOrAfter(actual, target)
% Compare release strings such as R2025b/2025b and R2026a without newer helpers.
[aYear, aHalf] = parseRelease(actual);
[tYear, tHalf] = parseRelease(target);
tf = (aYear > tYear) || (aYear == tYear && aHalf >= tHalf);
end

function [yearValue, halfValue] = parseRelease(r)
expr = '^R?(\d{4})([ab])$';
t = regexp(r, expr, 'tokens', 'once');
if isempty(t)
    yearValue = -inf;
    halfValue = -inf;
    return;
end
yearValue = str2double(t{1});
if strcmpi(t{2}, 'a')
    halfValue = 1;
else
    halfValue = 2;
end
end

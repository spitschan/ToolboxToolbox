function [results, prefs] = tbDeployToFolder(rootFolder, varargin)
% Deploy toolboxes to a given rootFolder, instead of toolboxRoot.
%
% This is a convenience wrapper around tbDeployToolboxes().  It deployes
% toolboxes to the given rootFolder, regardless of the currently configured
% toolboxCommonRoot, toolboxRoot, or projectRoot, or any toolboxRoot field
% specified in toolbox records.  This is useful for temporary deployments
% that should be kept separate from regular toolboxes and proects, and
% should be easy to delete.
%
% results = tbDeployToFolder() fetches each toolbox from the default
% toolbox configuration into the given rootFolder and adds each to the
% Matlab path.  Returns a struct of results about what happened for each
% toolbox.
%
% tbDeployToFolder(... 'config', config) deploy the given struct array of
% toolbox records instead of the default toolbox configuration.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2017 benjamin.heasly@gmail.com

[prefs, others] = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('rootFolder', @ischar);
parser.addParamValue('config', [], @(c) isempty(c) || isstruct(c));
parser.parse(rootFolder, others);
rootFolder = parser.Results.rootFolder;
config = parser.Results.config;


%% Choose explicit config, or load from file.
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = tbReadConfig(prefs);
end


%% Deploy everything into the given folder -- like it's a new machine.
prefs.configPath = fullfile(rootFolder, 'toolbox_config.json');
prefs.localHookFolder = fullfile(rootFolder, 'localToolboxHooks');
prefs.projectRoot = fullfile(rootFolder, 'projects');
prefs.toolboxCommonRoot = fullfile(rootFolder, 'toolboxes');
prefs.toolboxRoot = fullfile(rootFolder, 'toolboxes');

% explicitly point each toolbox record into the toolboxRoot
%   to make them easier to find later
config = tbDealField(config, 'toolboxRoot', prefs.toolboxRoot);


%% The rest of the deployment is the same as usual.
results = tbDeployToolboxes('config', config, prefs);

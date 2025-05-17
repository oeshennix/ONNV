local toml=require('toml-lua');
local module={};

function module.setup(config)
  config=config or {};
  module.path=config.path or {
    vim.fn.getcwd().."/.ONNV.toml",
    vim.fn.stdpath('data')..'/ONNV/config.toml',
  };
  module.a();
end

function module.findConfigFile()
  for c,v in ipairs(module.path)do
    if(vim.fn.findfile(v)~="")then
      return v;
    end;
  end;
end;

local utils=require("ONNV.utils");
local configfunctions=utils.configfunctions;


function UseConfig(configfile)
  configfile=configfile or module.findConfigFile();
  local ConfigFileBuffer=io.open(configfile,"r");
  assert(ConfigFileBuffer,"could not load config file");
  ConfigFileContents=ConfigFileBuffer:read("a")
  local Config=toml.parse(ConfigFileContents);
  Config=Config:Lua();

  vim.g.ONNVpath=configfile;
  vim.g.ONNVconfig=MorphTable(Config);
  module.config=Config;
end;

local LSPConfigurationPath=vim.fn.stdpath('data')..'/ONNV/config.toml';
function module.a()
  local configfile=module.findConfigFile()
  if(not configfile)then
    configfile=LSPConfigurationPath;
    vim.uv.fs_mkdir(vim.fn.stdpath('data')..'/ONNV',tonumber('700',8));
    fd=vim.uv.fs_open(LSPConfigurationPath,"w",tonumber("600",8));
    vim.uv.fs_write(fd,
[=[#lsp
startup=[]
]=]);
    vim.uv.fs_close(fd);
  end
  vim.api.nvim_create_user_command('EditONNVconfig',function(args)
    for c,v in pairs(args)do
      print(c,v);
    end
    vim.cmd.new(vim.g.ONNVpath);
  end,{
  });

  UseConfig();

end;

function module.getConfig()
  return module.config;
end;

return module;

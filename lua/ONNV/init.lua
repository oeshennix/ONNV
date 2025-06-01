local toml=require('toml-lua');
local module={};
--[[
module.path={};
module.pathname={};

function module.appendpath(name,nickname)

end
]]

function module.setup(config)
  config=config or {};
  module.path=config.path or {
    vim.fn.getcwd().."/.ONNV.toml",
    vim.fn.stdpath('data')..'/ONNV/config.toml',
  };
  --[[
  config.pathname={
    "./.ONNV.toml",
    "data/ONNV/config.toml"
  }
  ]]
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

function module.retrieve(configfile)
  assert(vim.fn.findfile(configfile)~="","could not use config file");
  local ConfigFileBuffer=io.open(configfile,"r");
  assert(ConfigFileBuffer,"could not load config file");
  ConfigFileContents=ConfigFileBuffer:read("a")
  local Config=toml.parse(ConfigFileContents);
  Config=Config:Lua();
  return MorphTable(Config);
end
function UseConfig(configfile)
  configfile=configfile or module.findConfigFile();
  local Config=module.retrieve(configfile)

  vim.g.ONNVpath=configfile;
  vim.g.ONNVconfig=Config;
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
  vim.api.nvim_create_user_command('EditONNVconfig',function(info)
    if(#info.fargs==0)then
      vim.cmd.new(vim.g.ONNVpath);
    else
      local val=vim.iter(module.path):find(info.fargs[1])
      if(not val)then
        vim.print(string.format("\"%s\" is not a ONNVpath",info.fargs[1]));
        return
      end
      vim.cmd.new(info.fargs[1]);
    end
  end,{
    nargs="?",
    complete=function()
      return module.path
    end
  });

  UseConfig();

end;

function module.getConfig()
  return module.config;
end;

return module;

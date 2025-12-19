--local toml=require('toml-lua');
local tinytoml=require('ONNV.tinytoml');
local morph=require("ONNV.morph");
local module={};

local function UseConfig(configfile)
  configfile=configfile or module.findConfigFile();
  local Config=module.retrieve(configfile)

  vim.g.ONNVpath=configfile;
  vim.g.ONNVconfig=Config;
  module.config=Config;
end;

function module.setup(config)
  config=config or {};
  module.path=config.path or {
    vim.fn.getcwd().."/.ONNV.toml",
    vim.fn.stdpath('config')..'/ONNV/config.toml',
  };

  local configfile=module.findConfigFile()
  if(not configfile)then
    print("Could not find config files");
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
  UseConfig(configfile);
end

function module.findConfigFile()
  for c,v in ipairs(module.path)do
    if(vim.fn.findfile(v)~="")then
      return v;
    end;
  end;
end;


function module.retrieve(configfile)
  --[[
  assert(vim.fn.findfile(configfile)~="","could not use config file");
  local ConfigFileBuffer=io.open(configfile,"r");
  assert(ConfigFileBuffer,"could not load config file");
  ConfigFileContents=ConfigFileBuffer:read("a")
  local Config=toml.parse(ConfigFileContents);
  Config=Config:Lua();
  --]]
  local Config=tinytoml.parse(configfile);
  return Config;
end


function module.getConfig()
  return module.config;
end;

return module;

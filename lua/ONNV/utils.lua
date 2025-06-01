local toml=require('toml-lua');
local configfunctions={}

---@param tab table;
---@return table
function MorphTable(tab)
  for name,value in pairs(tab)do
    if(string.sub(name,1,1)=="$")then
      if(string.sub(name,2,2)==".")then
        print("not implemented")
      elseif(string.sub(name,2,2)=="$")then
        local newname=string.sub(name,3);
        tab[name]=nil;
        tab[newname]=value
        if(type(value)=="table")then
          MorphTable(value);
        end;
      else
        local newname=string.sub(name,2);
        tab[name]=nil;
        local func=value[1];
        assert(configfunctions[func],string.format("configfunction \"%s\" not found",func))
        if(configfunctions[func])then
          tab[newname]=configfunctions[func](value);
        end
      end
    elseif(type(value)=="table")then
      MorphTable(value);
    end;
  end
  return tab;
end

local pathfunc={};

pathfunc.nvim=vim.fn.stdpath

---@param path string
function GetONNVpath(path)
  if(string.sub(path,1,1)~="$")then
    return path;
  end
  local command,data,extension=string.match(path,"$([%w_]+)%((.*)%)/(.*)")
  return pathfunc[command](data).."/"..extension;
end
configfunctions.require=function(tab)
  require(tab[1]);
end
configfunctions.userequire=function(tab)
  local path=tab[1];
  table.remove(tab,1);

  require(path)(tab);
end
function configfunctions.uselua(tab)
  local file=GetONNVpath(tab[2]);
  assert(vim.fn.findfile(file)~="",string.format("file \"%s\" does not exist",file))
  return dofile(file);
end
function configfunctions.path(tab)
  return GetONNVpath(tab[2]);
end
function configfunctions.toml(tab)
  local file=GetONNVpath(tab[2]);
  assert(vim.fn.findfile(file)~="",string.format("file \"%s\" does not exist",file))
  local ConfigFileBuffer=io.open(file,"r");
  assert(ConfigFileBuffer,"could not open file \"%s\"",file);
  ConfigFileContents=ConfigFileBuffer:read("a")
  local Config=toml.parse(ConfigFileContents);
  Config=Config:Lua();
  return MorphTable(Config);
end
return {configfunctions=configfunctions};

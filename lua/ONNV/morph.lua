local M={};

local morphers={}

local function findintable(t,val)
  for c,v in pairs(t)do
    if(v==val)then
      return true
    end
  end
end

function M.morphValue(tab,baseconfig,allowed)
    if(type(tab)~="table")then
      return tab;
    end;
    assert(findintable(allowed,tab[1]),string.format("morpher %s is not allowed",tab[1]))
    return morphers[tab[1]](tab,baseconfig,allowed);
end

function morphers.concat(tab,baseconfig,allowed)
  local s="";
  for c=2,#tab do
    v=tab[c];
    if(type(v)=="string")then
      s=s..v
    elseif(type(v)=="table")then
      local b=M.morphValue(v,baseconfig,allowed);
      s=s..b;
    end
  end
  return s;
end

function morphers.var(tab,baseconfig,allowed)
  return baseconfig.variables[tab[2]];
end
function morphers.env(tab,baseconfig,allowed)
  return vim.env[tab[2]];
end

function M.morph(tab,baseconfig,allowed)
  for name,value in pairs(tab)do
    tab[name]=M.morphValue(value,baseconfig,allowed);
  end
end
M.morphers=morphers;

return M;

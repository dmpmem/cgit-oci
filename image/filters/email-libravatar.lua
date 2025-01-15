-- This script may be used with the email-filter or repo.email-filter settings in cgitrc.
-- It adds libravatar icons to author names. It is designed to be used with the lua:
-- prefix in filters.
--
-- Requirements:
--      luaossl
--      <http://25thandclement.com/~william/projects/luaossl.html>
--

local digest = require('openssl.digest')

function sha256_hex(input)
  local b = digest.new('sha256'):final(input)
  local x = ''
  for i = 1, #b do
    x = x .. string.format('%.2x', string.byte(b, i))
  end
  return x
end

function filter_open(email, page)
  buffer = ''
  sha256 = sha256_hex(email:sub(2, -2):lower())
end

function filter_close()
  baseurl = not os.getenv('FORCE_HTTP') and 'https://seccdn.libravatar.org/' or 'http://cdn.libravatar.org/'
  local url = baseurl .. 'avatar/' .. sha256 .. '?d=retro&amp;s='
  local rng = tostring(math.random(0, 10000000))
  -- very bad email obfuscation
  html(
    '<a class=\'e-'
      .. sha256
      .. '\' id=\'e-'
      .. rng
      .. '\'><span class="libravatar-avatar"><img src=\''
      .. url
      .. '128\' class="always-visible" alt=\'Libravatar\' /><img src=\''
      .. url
      .. '1024\' class=\'on-hover\' alt=\'Large Libravatar\' /></span> '
      .. buffer:gsub('@', '<span class="theattening"></span>'):gsub('%.', '<span class="thedottening"></span>')
      .. '</a>'
      .. (
        math.random(0, 1000) < 777
          and '<script id="j-' .. rng .. '">(()=>{const _=' .. (math.random(0, 100) > 50 and 'setTimeout' or 'setInterval') .. '(()=>{const a=document.querySelector(\'#e-' .. rng .. '.e-' .. sha256 .. '\');a.removeAttribute(\'id\');const b = a.querySelector(".theattening");if(b){b.outerHTML+="<span style=\'display:inline-flex;flex-direction:row-reverse;width:0;height:0;opacity:0;\'><span>a</span><span>t</span></span>";a.querySelector(".thedottening").outerHTML=String.fromCharCode(("http://").charCodeAt(5) - 1);};document.querySelector("#j-' .. rng .. '").remove();try{clearInterval(_);}catch(e){}},' .. tostring(
            math.random(0, 1000)
          ) .. ')})()</script>'
        or ''
      )
  )
  return 0
end

function filter_write(str)
  buffer = buffer .. str
end

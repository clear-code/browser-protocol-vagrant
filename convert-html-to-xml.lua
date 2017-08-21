local chrome_devtools = require("chrome-devtools-client")
pgmoon = require("pgmoon-mashape")

function split_text(text, delimiter)
  if text.find(text, delimiter) == nil then
    return { text }
  end

  local splited_text = {}
  local last_position

  for synonym, position in text:gmatch("(.-)"..delimiter.."()") do
    table.insert(splited_text, synonym)
    last_position = position
  end
  table.insert(splited_text, string.sub(text, last_position))

  return splited_text
end

function parse_connection_spec(connection_spec)
  parsed_connection_spec = {}
  for number, connection_spec_value in pairs(split_text(connection_spec, " ")) do
    key, value = connection_spec_value:match("(.-)=(.-)$")
    parsed_connection_spec[key] = value
  end
  return parsed_connection_spec
end

function save_xml(connection_spec, xml)
  parsed_connection_spec = parse_connection_spec(connection_spec)
  local pg = pgmoon.new(parsed_connection_spec)
  assert(pg:connect())

  assert(pg:query("CREATE TABLE IF NOT EXISTS contents("..
                  "id serial,"..
                  "xml text"..
                  ");"))
  assert(pg:query("INSERT INTO contents (xml)"..
                  "VALUES (XMLPARSE(DOCUMENT " .. pg:escape_literal(xml) .. "))"))
end

function fcopy(src_path, dst_path)
  src_file = io.open(src_path, "r")
  dst_file = io.open(dst_path, "w")
  dst_file:write(src_file:read('*all'))
  src_file:close()
  dst_file:close()
end

function send_file_to_vm(vm_ip, src_path, dst_path)
  os.execute("scp -P 2222 -i .vagrant/machines/browser-protocol/virtualbox/private_key "..
             src_path.." vagrant@"..vm_ip..":"..dst_path)
end

if #arg == 2 or #arg == 3 then
else
  print("Usage: "..arg[0].." CONNECTION_SPEC SOURCE_HTML")
  print(" e.g.: "..arg[0].." 'database=test_db user=postgres' source.html")
  return 1
end

if arg[3] == nil then
  shared_directory_path = "./"
else
  shared_directory_path = arg[3]
end

fcopy(arg[2], shared_directory_path.."in.html")

local connect_ip = "192.168.92.22"
local connect_port = "9223"
local client = chrome_devtools.connect(connect_ip, connect_port)

client:page_navigate("file:///vagrant/in.html")
client:close()

client = chrome_devtools.connect(connect_ip, connect_port)
xml = client:convert_html_to_xml()
save_xml(arg[1], xml)
print(xml)
print("Save XML finished")
client:close()
assert(os.remove(shared_directory_path.."in.html"))

local chrome_devtools = require("chrome-devtools-client")
pgmoon = require("pgmoon-mashape")

function split_text(text, delimiter)
  if text.find(text, delimiter) == nil then
    return { text }
  end

  local splited_texts = {}
  local last_position

  for splited_text, position in text:gmatch("(.-)"..delimiter.."()") do
    table.insert(splited_texts, splited_text)
    last_position = position
  end
  table.insert(splited_texts, string.sub(text, last_position))

  return splited_texts
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

  assert(pg:query("CREATE TABLE IF NOT EXISTS converted_xml_contents("..
                  "id serial,"..
                  "xml xml"..
                  ");"))
  assert(pg:query("INSERT INTO converted_xml_contents (xml)"..
                  "VALUES (XMLPARSE(DOCUMENT " .. pg:escape_literal(xml) .. "))"))
end

function fcopy(src_path, dst_path)
  src_file = io.open(src_path, "r")
  dst_file = io.open(dst_path, "w")
  dst_file:write(src_file:read('*all'))
  src_file:close()
  dst_file:close()
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
client:close()
assert(os.remove(shared_directory_path.."in.html"))
os.exit(0)

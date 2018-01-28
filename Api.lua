dofile('./Config.lua')
local http = require("socket.http")
local https = require("ssl.https")
local serpent = require("serpent")
local socket = require("socket")
local ltn12 = require("ltn12")
local URL = require("socket.url")
local json = (loadfile "./libs/JSON.lua")()
local redis1 = require("redis")
local redis = redis1.connect("127.0.0.1", 6379)
local Bot_Api = 'https://api.telegram.org/bot' ..token
local offset = 0 
minute = 60
hour = 3600
day = 86400
week = 604800 
MsgTime = os.time() - 5
-----CerNer Company
function is_sudo(msg)
  local var = false
  for v,user in pairs(SUDO_ID) do
    if user == user then
      var = true
    end
  end
  return var
end
function is_Mod(chat_id,user_id)
local var = false
for v,user in pairs(SUDO_ID) do
if user == user_id then
var = true
end
end
local owner = redis:sismember('OwnerList:'..chat_id,user_id)
local hash = redis:sismember('ModList:'..chat_id,user_id)
if hash or owner then
var=  true
end
return var
end
  function is_Owner(chat_id,user_id)
local var = false
for v,user in pairs(SUDO_ID) do
if user== user_id then
var = true
end
end
local hash = redis:sismember('OwnerList:'..chat_id,user_id)
if hash then
var=  true
end
return var
end

local function vardump(value)
print(serpent.block(value, {comment = false}))
end
local function getUpdates()
local response = {}
local success, code, headers, status  = https.request{
url = Bot_Api .. '/getUpdates?timeout=20&limit=1&offset=' .. offset,
method = "POST",
 sink = ltn12.sink.table(response),
  }
local body = table.concat(response or {"no response"})
  if (success == 1) then
return json:decode(body)
  else
return nil, "Request Error"
 end
end
-----------------------
function AnswerInline(inline_query_id, query_id , title , description , text,parse_mode, keyboard)
local results = {{}}
 results[1].id = query_id
results[1].type = 'article'
results[1].description = description
results[1].title = title
results[1].message_text = text
results[1].parse_mode = parse_mode
Rep= Bot_Api .. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=&cache_time=' .. 1
if keyboard then
results[1].reply_markup = keyboard
Rep = Bot_Api.. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=Markdown&cache_time=' .. 1
end
https.request(Rep)
end
 function downloadFile(file_id, download_path)
if not file_id then return nil, "file_id not specified" end
if not download_path then return nil, "download_path not specified" end
local response = {}
local file_info = getFile(file_id)
local download_file_path = download_path or "downloads/" .. file_info.result.file_path
local download_file = io.open(download_file_path, "w")
if not download_file then return nil, "download_file could not be created"
else
local success, code, headers, status = https.request{
url = "https://api.telegram.org/file/bot" ..token.. "/" .. file_info.result.file_path,
--source = ltn12.source.string(body),
sink = ltn12.sink.file(download_file),
 }
local r = {
 success = true,
download_path = download_file_path,
file = file_info.result
 }
return r
end
end
function es_name(name) 
  if name:match('_') then
   name = name:gsub('_','')
  end
	if name:match('*') then
   name = name:gsub('*','')
  end
	if name:match('`') then
   name = name:gsub('`','')
  end
 return name
end
function SendInline(chat_id, text, keyboard, reply_to_message_id, markdown)
local url = Bot_Api.. '/sendMessage?chat_id=' .. chat_id
if reply_to_message_id then
url = url .. '&reply_to_message_id=' .. reply_to_message_id
end
if markdown == 'md' or markdown == 'markdown' then
url = url..'&parse_mode=Markdown'
elseif markdown == 'html' then
url = url..'&parse_mode=HTML'
end
url = url..'&text='..URL.escape(text)
url = url..'&disable_web_page_preview=true'
url = url..'&reply_markup='..URL.escape(JSON.encode(keyboard))
return https.request(url)
end
function getUserProfilePhotos(user_id, offset, limit)
local Rep = Bot_Api.. '/getUserProfilePhotos?user_id='..user_id
if offset then
Rep = Rep..'&offset='..offset
end
if limit then
if tonumber(limit) > 100 then 
limit = 100 
end
Rep = Rep..'&limit='..limit
end
return https.request(Rep)
end
function run_command(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
end
function string:isempty()
  return self == nil or self == ''
end
function Leave(chat_id)
local Rep = Bot_API.. '/leaveChat?chat_id=' .. chat_id
return https.request(Rep)
end
function deletemessages(chat_id, message_id)
local Rep = Bot_Api..'/deletemessage?chat_id='..chat_id..'&message_id='..message_id
return https.request(Rep)
end
function Pin(chat_id, msg_id)
local Rep = Bot_Api..'/pinChatMessage?chat_id='..chat_id..'&message_id='..msg_id
return https.request(Rep)
end
function  changeChatDescription(chat_id, des)
local Rep = Bot_Api..'/setChatDescription?chat_id='..chat_id..'&description='..des
 return https.request(Rep)
end
function unpin(chat_id)
local Rep = Bot_Api..'/unpinChatMessage?chat_id='..chat_id
return https.request(Rep)
end 
function Unban(chat_id, user_id)
local Rep = Bot_Api.. '/unbanChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
return https.request(Rep)
end
function CheckChatmember(chat_id, user_id)
local Rep = Bot_Api.. '/unbanChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
return https.request(Rep)
end
function KickUser(user_id, chat_id)
local Rep = Bot_Api.. '/kickChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
return https.request(Rep)
end
function get_http_file_name(url, headers)
  local file_name = url:match("[^%w]+([%.%w]+)$")
  file_name = file_name or url:match("[^%w]+(%w+)[^%w]+$")
  file_name = file_name or str:random(5)
  local content_type = headers["content-type"]
  local extension = nil
  if content_type then
    extension = mimetype.get_mime_extension(content_type)
  end
  if extension then
    file_name = file_name.."."..extension
  end
  local disposition = headers["content-disposition"]
  if disposition then
    file_name = disposition:match('filename=([^;]+)') or file_name
  end
  return file_name
end
function download_to_file(url, file_name)
  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local response = nil
  if url:starts('https') then
    options.redirect = false
    response = {https.request(options)}
  else
    response = {http.request(options)}
  end
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  file_name = file_name or get_http_file_name(url, headers)
  local file_path = "data/"..file_name
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
function sendPhoto(chat_id, file_id, reply_to_message_id, caption)
local Rep = Bot_Api.. '/sendPhoto?chat_id=' .. chat_id .. '&photo=' .. file_id
if reply_to_message_id then
Rep = Rep..'&reply_to_message_id='..reply_to_message_id
end
if caption then
Rep = Rep..'&caption='..URL.escape(caption)
end
return https.request(Rep)
end
function string:input()
if not self:find(' ') then
return false
end
return self:sub(self:find(' ')+1)
end

function getFile(file_id)
local Rep = Bot_Api.. '/getFile?file_id='..file_id
return https.request(Rep)
end
function EditInline( message_id, text, keyboard)
local Rep =  Bot_Api.. '/editMessageText?&inline_message_id='..message_id..'&text=' .. URL.escape(text)
Rep=Rep .. '&parse_mode=Markdown'
if keyboard then
Rep=Rep..'&reply_markup='..URL.escape(json:encode(keyboard))
 end
return https.request(Rep)
 end
function Alert(callback_query_id, text, show_alert)
local Rep = Bot_Api .. '/answerCallbackQuery?callback_query_id=' .. callback_query_id .. '&text=' .. URL.escape(text)
if show_alert then
Rep = Rep..'&show_alert=true'
end
https.request(Rep)
end
function sendText(chat_id, text, reply_to_message_id, markdown)
	local url = Bot_Api .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)
	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end
  if markdown == 'md' or markdown == 'markdown' then
    url = url..'&parse_mode=Markdown'
  elseif markdown == 'html' then
    url = url..'&parse_mode=HTML'
  end
	return https.request(url)
end
---------------------------

local function Running()
 while true do
local updates = getUpdates()
if updates and updates.result then
for i = 1, #updates.result do
local msg= updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match('-%d+') then
chat_id = '-'..Company.query:match('%d+')
redis:set('chat',chat_id)
if Company.from.id == TD_ID or Company.from.id == Sudoid then
if redis:get('CheckBot:'..chat_id) then
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️ تنظیمات و مدیریت گروه ', callback_data = 'Menu:'..chat_id}},{{text= '▪️ بستن فهرست مدیریتی' ,callback_data = 'Exit:'..chat_id}},{{text="▪️ کانال تیم ما",url="https://telegram.me/RexCompany"}}}
AnswerInline(Company.id,'settings','Group settings',chat_id,'▪️ به فهرست مدیریتی گروه خوش آمدید','Markdown',keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text="▪️ کانال تیم ما",url="https://telegram.me/RexCompany"}}}			
AnswerInline(Company.id,'Not OK','Group Not Found',chat_id,'▪️ `کاربر :` _'..Company.from.first_name..'_ `شما دسترسی کافی برای این کار را ندارید`','Markdown',keyboard)
end
end
end
end
----------Msg.Type-----------------------
if (updates.result) then
for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.message then
local CerNer = msg.message
cerner = CerNer.text
msg.chat_id = CerNer.chat.id
msg.id =  CerNer.message_id
cerner = CerNer.text
msg.user_first = CerNer.from.first_name
msg.user_id = CerNer.from.id
msg.chat_title = CerNer.chat.title

name = es_name(msg.user_first)
first = '['..name..'](tg://user?id='..msg.user_id..')'
if cerner == '(.*)' then
Leave(msg.chat_id)
end
-------------------------------
end 
end
end
-----------------------------------
if cerner then
print(""..cerner.." : Sender : "..(msg.user_id or 'nil').."\nThis is [ TEXT ]")
end
if (updates.result) then
for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match('%d+') then
local keyboard = {}
keyboard.inline_keyboard = {{{text="▪️ کانال تیم ما",url="https://telegram.me/"..ChannelInline..""}}}
AnswerInline(Company.id,'Click To See User','Click To See User',Company.query:match('%d+'),'[▪️ برای دیدن اطلاعات کاربر کلیک کنید](tg://user?id='..Company.query:match('%d+')..')','Markdown',keyboard)
end
end
 end
end
 if (updates.result) then
 for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match("+(.*)") then
local link = Company.query:match("+(.*)")
AnswerInline(Company.id,'mod','GetLink','Url','[URL]('..link..')','Markdown',nil)
end
end
end
end
if msg.callback_query then
local Company = msg.callback_query
cerner = Company.data
msg.user_first= Company.from.first_name
chat_id = '-'..Company.data:match('(%d+)')
msg.inline_id = Company.inline_message_id
if not is_Mod(chat_id,Company.from.id) then
Alert(Company.id,'▪️ کاربر '..msg.user_first..' شما دسترسی کافی ندارید',true)
else
if cerner == 'cerner'..chat_id..'' then
Alert(Company.id,"▪️ داری اشتباه میزنی ヅ")
else
if cerner == 'Menu:' or 'فهرست'..chat_id..'' then
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▫️ تنظیمات گروه', callback_data = 'management:'..chat_id}
},{{text = '▫️ ❕اطلاعات گروه', callback_data = 'groupinfo:'..chat_id}
},{{text = '▫️ ✖️بستن فهرست مدیریتی', callback_data = 'Exit:'..chat_id}}}
EditInline(msg.inline_id,'▪️ به بخش مدیریت گروه خوش آمدید :\n'..msg.user_first..'',keyboard)
end
if cerner == 'management:'..chat_id then
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ تنظیمات', callback_data = 'Settings:'..chat_id},{text =  '▪️ تنظیمات بیشتر', callback_data = 'moresettings:'..chat_id}
},{
{text =  '▪️ تنظیمات سکوت', callback_data = 'Mutelist:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'Menu:'..chat_id}}}
EditInline(msg.inline_id,'▪️ به بخش تنظیمات خوش آمدید :\n'..msg.user_first..'',keyboard)
end
if cerner == 'Settings:'..chat_id then
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک : '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '🔜 صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lock edit:'..chat_id then
if redis:get('Lock:Edit'..chat_id) then
redis:del('Lock:Edit'..chat_id)
Alert(Company.id, "▫️ قفل ویرایش پیام ✖️غیرفعال شد !")
else
redis:set('Lock:Edit'..chat_id,true)
Alert(Company.id, "▫️ قفل ویرایش پیام  فعال شد ً!")
	end
 if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک : '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lock link:'..chat_id then
if redis:get('Lock:Link'..chat_id) then
redis:del('Lock:Link'..chat_id)
Alert(Company.id, "▫️ قفل ارسال لینک ✖️غیرفعال شد !")
else
redis:set('Lock:Link'..chat_id,true)
Alert(Company.id, "▫️ قفل ارسال لینک فعال شد ً!")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک : '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockmarkdown:'..chat_id then
if redis:get('Lock:Markdown:'..chat_id) then
redis:del('Lock:Markdown:'..chat_id)
Alert(Company.id, "▫️ قفل نشانه گذاری ✖️غیرفعال شد")
else
redis:set('Lock:Markdown:'..chat_id,true)
Alert(Company.id, "▫️ قفل  نشانه گذاری فعال شد!")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک : '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
----------------------------------------------------------------
if cerner == 'Exit:'..chat_id..'' then
EditInline(msg.inline_id,'▪️ فهرست شیشه ای با موفقیت بسته شد.',keyboard)
end
if cerner == 'pagenext:'..chat_id then
if redis:get('Lock:Forward:'..chat_id) then
fwd = '✔️فعال'
else
fwd = '✖️غیرفعال' 
end
if redis:get('Lock:Arabic:'..chat_id) then
arabic = '✔️فعال'
else
arabic = '✖️غیرفعال' 
end
if redis:get('Lock:English:'..chat_id) then
english = '✔️فعال'
else
english = '✖️غیرفعال' 
end
if redis:get('Lock:TGservise:'..chat_id) then
tgservise = '✔️فعال'
else
tgservise = '✖️غیرفعال' 
end
if redis:get('Lock:Sticker:'..chat_id) then
sticker = '✔️فعال'
else
sticker = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 2`'
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️فوروارد : '..fwd..'', callback_data = 'lockforward:'..chat_id}}
,{{text = '▪️فارسی : '..arabic..'', callback_data = 'lockarabic:'..chat_id}}
,{{text = '▪️انگلیسی : '..english..'', callback_data = 'lockenglish:'..chat_id}}
,{{text = '▪️سرویس تلگرام  : '..tgservise..'', callback_data = 'locktgservise:'..chat_id}}
,{{text = '▪️استیکر : '..sticker..'', callback_data = 'locksticker:'..chat_id}}
,{{text = '🔙 بازگشت', callback_data = 'Settings:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockforward:'..chat_id then
if redis:get('Lock:Forward:'..chat_id) then
redis:del('Lock:Forward:'..chat_id)
Alert(Company.id,"▫️ قفل فوروارد✖️غیرفعال شد")
else
redis:set('Lock:Forward:'..chat_id,true)
Alert(Company.id,"▫️ قفل فوروارد فعال شد")
end
if redis:get('Lock:Forward:'..chat_id) then
fwd = '✔️فعال'
else
fwd = '✖️غیرفعال' 
end
if redis:get('Lock:Arabic:'..chat_id) then
arabic = '✔️فعال'
else
arabic = '✖️غیرفعال' 
end
if redis:get('Lock:English:'..chat_id) then
english = '✔️فعال'
else
english = '✖️غیرفعال' 
end
if redis:get('Lock:TGservise:'..chat_id) then
tgservise = '✔️فعال'
else
tgservise = '✖️غیرفعال' 
end
if redis:get('Lock:Sticker:'..chat_id) then
sticker = '✔️فعال'
else
sticker = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 2`'
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️فوروارد : '..fwd..'', callback_data = 'lockforward:'..chat_id}}
,{{text = '▪️فارسی: '..arabic..'', callback_data = 'lockarabic:'..chat_id}}
,{{text = '▪️انگلیسی : '..english..'', callback_data = 'lockenglish:'..chat_id}}
,{{text = '▪️سرویس تلگرام  : '..tgservise..'', callback_data = 'locktgservise:'..chat_id}}
,{{text = '▪️استیکر : '..sticker..'', callback_data = 'locksticker:'..chat_id}}
,{{text = '🔙 بازگشت', callback_data = 'Settings:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockarabic:'..chat_id then
if redis:get('Lock:Arabic:'..chat_id) then
redis:del('Lock:Arabic:'..chat_id)
Alert(Company.id,"▫️ قفل زبان عربی ✖️غیرفعال شد")
else
redis:set('Lock:Arabic:'..chat_id,true)
Alert(Company.id,"▫️ قفل زبان عربی فعال شد")
end
if redis:get('Lock:Forward:'..chat_id) then
fwd = '✔️فعال'
else
fwd = '✖️غیرفعال' 
end
if redis:get('Lock:Arabic:'..chat_id) then
arabic = '✔️فعال'
else
arabic = '✖️غیرفعال' 
end
if redis:get('Lock:English:'..chat_id) then
english = '✔️فعال'
else
english = '✖️غیرفعال' 
end
if redis:get('Lock:TGservise:'..chat_id) then
tgservise = '✔️فعال'
else
tgservise = '✖️غیرفعال' 
end
if redis:get('Lock:Sticker:'..chat_id) then
sticker = '✔️فعال'
else
sticker = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 2`'
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️فوروارد : '..fwd..'', callback_data = 'lockforward:'..chat_id}}
,{{text = '▪️فارسی: '..arabic..'', callback_data = 'lockarabic:'..chat_id}}
,{{text = '▪️انگلیسی : '..english..'', callback_data = 'lockenglish:'..chat_id}}
,{{text = '▪️سرویس تلگرام  : '..tgservise..'', callback_data = 'locktgservise:'..chat_id}}
,{{text = '▪️استیکر : '..sticker..'', callback_data = 'locksticker:'..chat_id}}
,{{text = '🔙 بازگشت', callback_data = 'Settings:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockenglish:'..chat_id then
if redis:get('Lock:English:'..chat_id) then
redis:del('Lock:English:'..chat_id)
Alert(Company.id,"▫️ قفل زبان انگلیسی ✖️غیرفعال شد")
else
redis:set('Lock:English:'..chat_id,true)
Alert(Company.id,"▫️ قفل زبان انگلیسی فعال شد")
end
if redis:get('Lock:Forward:'..chat_id) then
fwd = '✔️فعال'
else
fwd = '✖️غیرفعال' 
end
if redis:get('Lock:Arabic:'..chat_id) then
arabic = '✔️فعال'
else
arabic = '✖️غیرفعال' 
end
if redis:get('Lock:English:'..chat_id) then
english = '✔️فعال'
else
english = '✖️غیرفعال' 
end
if redis:get('Lock:TGservise:'..chat_id) then
tgservise = '✔️فعال'
else
tgservise = '✖️غیرفعال' 
end
if redis:get('Lock:Sticker:'..chat_id) then
sticker = '✔️فعال'
else
sticker = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 2`'
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️فوروارد : '..fwd..'', callback_data = 'lockforward:'..chat_id}}
,{{text = '▪️فارسی: '..arabic..'', callback_data = 'lockarabic:'..chat_id}}
,{{text = '▪️انگلیسی : '..english..'', callback_data = 'lockenglish:'..chat_id}}
,{{text = '▪️سرویس تلگرام  : '..tgservise..'', callback_data = 'locktgservise:'..chat_id}}
,{{text = '▪️استیکر : '..sticker..'', callback_data = 'locksticker:'..chat_id}}
,{{text = '🔙 بازگشت', callback_data = 'Settings:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'locktgservise:'..chat_id then
if redis:get('Lock:TGservise:'..chat_id) then
redis:del('Lock:TGservise:'..chat_id)
Alert(Company.id,"▫️ قفل  حدف پیام ورود خروج ✖️غیرفعال شد ")
else
redis:set('Lock:TGservise:'..chat_id,true)
Alert(Company.id,"▫️ قفل  حدف پیام ورود خروج فعال شد")
end
if redis:get('Lock:Forward:'..chat_id) then
fwd = '✔️فعال'
else
fwd = '✖️غیرفعال' 
end
if redis:get('Lock:Arabic:'..chat_id) then
arabic = '✔️فعال'
else
arabic = '✖️غیرفعال' 
end
if redis:get('Lock:English:'..chat_id) then
english = '✔️فعال'
else
english = '✖️غیرفعال' 
end
if redis:get('Lock:TGservise:'..chat_id) then
tgservise = '✔️فعال'
else
tgservise = '✖️غیرفعال' 
end
if redis:get('Lock:Sticker:'..chat_id) then
sticker = '✔️فعال'
else
sticker = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 2`'
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️فوروارد : '..fwd..'', callback_data = 'lockforward:'..chat_id}}
,{{text = '▪️فارسی: '..arabic..'', callback_data = 'lockarabic:'..chat_id}}
,{{text = '▪️انگلیسی : '..english..'', callback_data = 'lockenglish:'..chat_id}}
,{{text = '▪️سرویس تلگرام  : '..tgservise..'', callback_data = 'locktgservise:'..chat_id}}
,{{text = '▪️استیکر : '..sticker..'', callback_data = 'locksticker:'..chat_id}}
,{{text = '🔙 بازگشت', callback_data = 'Settings:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'locksticker:'..chat_id then
if redis:get('Lock:Sticker:'..chat_id) then
redis:del('Lock:Sticker:'..chat_id)
Alert(Company.id,"▫️ قفل  استیکر ✖️غیرفعال شد")
else
redis:set('Lock:Sticker:'..chat_id,true)
Alert(Company.id,"▫️ قفل  استیکر فعال شد")
end
if redis:get('Lock:Forward:'..chat_id) then
fwd = '✔️فعال'
else
fwd = '✖️غیرفعال' 
end
if redis:get('Lock:Arabic:'..chat_id) then
arabic = '✔️فعال'
else
arabic = '✖️غیرفعال' 
end
if redis:get('Lock:English:'..chat_id) then
english = '✔️فعال'
else
english = '✖️غیرفعال' 
end
if redis:get('Lock:TGservise:'..chat_id) then
tgservise = '✔️فعال'
else
tgservise = '✖️غیرفعال' 
end
if redis:get('Lock:Sticker:'..chat_id) then
sticker = '✔️فعال'
else
sticker = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 2`'
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️فوروارد : '..fwd..'', callback_data = 'lockforward:'..chat_id}}
,{{text = '▪️فارسی: '..arabic..'', callback_data = 'lockarabic:'..chat_id}}
,{{text = '▪️انگلیسی : '..english..'', callback_data = 'lockenglish:'..chat_id}}
,{{text = '▪️سرویس تلگرام  : '..tgservise..'', callback_data = 'locktgservise:'..chat_id}}
,{{text = '▪️استیکر : '..sticker..'', callback_data = 'locksticker:'..chat_id}}
,{{text = '🔙 بازگشت', callback_data = 'Settings:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end

---------------------------------------
if cerner == 'Mutelist:'..chat_id then
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutetext:'..chat_id then
if redis:get('Mute:Text:'..chat_id) then
redis:del('Mute:Text:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال متن ✖️غیرفعال شد")
else
redis:set('Mute:Text:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال متن فعال شد ")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = 'فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutecontact:'..chat_id then
if redis:get('Mute:Contact:'..chat_id) then
redis:del('Mute:Contact:'..chat_id)
Alert(Company.id,"▪️ قفل اشتراک گذاری مخاطب ✖️غیرفعال شد ")
else
redis:set('Mute:Contact:'..chat_id,true)
Alert(Company.id,"▪️ قفل  اشتراک گذاری مخاطب فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutegame:'..chat_id then
if redis:get('Mute:Game:'..chat_id) then
redis:del('Mute:Game:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال بازی ✖️غیرفعال شد")
else
redis:set('Mute:Game:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال بازی فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✔️✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '▪️ تنظیمات گروه  صفحه : 3'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutephoto:'..chat_id then
if redis:get('Mute:Photo:'..chat_id) then
redis:del('Mute:Photo:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال عکس ✖️غیرفعال شد")
else
redis:set('Mute:Photo:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال عکس فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutedocument:'..chat_id then
if redis:get('Mute:Document:'..chat_id) then
redis:del('Mute:Document:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال فایل ✖️غیرفعال شد")
else
redis:set('Mute:Document:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال فایل فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutevideo:'..chat_id then
if redis:get('Mute:Video:'..chat_id) then
redis:del('Mute:Video:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال ویدیو ✖️غیرفعال شد")
else
redis:set('Mute:Video:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال ویدیو فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutelocation:'..chat_id then
if redis:get('Mute:Location:'..chat_id) then
redis:del('Mute:Location:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال مکان ✖️غیرفعال شد")
else
redis:set('Mute:Location:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال مکان فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✔️✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutemusic:'..chat_id then
if redis:get('Mute:Music:'..chat_id) then
redis:del('Mute:Music:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال موزیک ✖️غیرفعال شد")
else
redis:set('Mute:Music:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال موزیک فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutevoice:'..chat_id then
if redis:get('Mute:Voice:'..chat_id) then
redis:del('Mute:Voice:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال صدا ✖️غیرفعال شد")
else
redis:set('Mute:Voice:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال صدا فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutegif:'..chat_id then
if redis:get('Mute:Gif:'..chat_id) then
redis:del('Mute:Gif:'..chat_id)
Alert(Company.id,"▪️ قفل ارسال گیف ✖️غیرفعال شد")
else
redis:set('Mute:Gif:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ارسال گیف فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutereply:'..chat_id then
if redis:get('Mute:Reply:'..chat_id) then
redis:del('Mute:Reply:'..chat_id)
Alert(Company.id,"▪️ قفل ریپلی ✖️غیرفعال شد")
else
redis:set('Mute:Reply:'..chat_id,true)
Alert(Company.id,"▪️ قفل  ریپلی فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'mutecaption:'..chat_id then
if redis:get('Mute:Caption:'..chat_id) then
redis:del('Mute:Caption:'..chat_id)
Alert(Company.id,"▪️ قفل کپشن ✖️غیرفعال شد")
else
redis:set('Mute:Caption:'..chat_id,true)
Alert(Company.id,"▪️ قفل  کپشن فعال شد")
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get('Mute:Text:'..chat_id) then
txts = '✔️فعال'
else
txts = '✖️غیرفعال'
end
if redis: get('Mute:Contact:'..chat_id) then
contact = '✔️فعال'
else 
contact = '✖️غیرفعال'
end
if redis:get('Mute:Document:'..chat_id) then
document = '✔️فعال'
else
document = '✖️غیرفعال'
end
if redis:get('Mute:Location:'..chat_id) then
location = '✔️فعال'
else
location = '✖️غیرفعال'
end
if redis:get('Mute:Voice:'..chat_id) then
voice = '✔️فعال'
else
voice = '✖️غیرفعال'
end
if redis:get('Mute:Photo:'..chat_id) then
photo = '✔️فعال'
else
photo = '✖️غیرفعال'
end
if redis:get('Mute:Game:'..chat_id) then
game = '✔️فعال'
else
game = '✖️غیرفعال'
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('Mute:Video:'..chat_id) then
video = '✔️فعال'
else
video = '✖️غیرفعال'
end
if redis:get('Mute:Music:'..chat_id) then
music = '✔️فعال'
else
music = '✖️غیرفعال'
end
if redis:get('Mute:Gif:'..chat_id) then
gif = '✔️فعال'
else
gif = '✖️غیرفعال'
end
if redis:get('Mute:Caption:'..chat_id) then
caption = '✔️فعال'
else
caption = '✖️غیرفعال'
end
if redis:get('Mute:Reply:'..chat_id) then
reply = '✔️فعال'
else
reply = '✖️غیرفعال' 
end
local text = '`▪️ تنظیمات گروه  صفحه : 3`'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️متن : '..txts..'', callback_data = 'mutetext:'..chat_id}
,{text = '▪️عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '▪️مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '▪️بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '▪️فایل : '..document..'', callback_data = 'mutedocument:'..chat_id}
,{text = '▪️فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '▪️موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id}
,{text = '▪️آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '▪️ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id}
},{
{text = '▪️گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},{text = '▪️ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '▪️عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
----------------------------------------
if cerner == 'moresettings:'..chat_id then
if redis:get('automuteall'..chat_id) then
auto= '✔️فعال'
else
auto= '✖️غیرفعال'
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg"  then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔️فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔️فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔️فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'locktag:'..chat_id then
if redis:get('Lock:Tag:'..chat_id) then
redis:del('Lock:Tag:'..chat_id)
Alert(Company.id,"▪️ قفل  تگ (@) ✖️غیرفعال شد")
else
redis:set('Lock:Tag:'..chat_id,true)
Alert(Company.id, "▪️ قفل  تگ (@) فعال شد")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک: '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockhashtag:'..chat_id then
if redis:get('Lock:HashTag:'..chat_id) then
redis:del('Lock:HashTag:'..chat_id)
Alert(Company.id,"▪️ قفل  هشتگ (#) ✖️غیرفعال شد !")
else
redis:set('Lock:HashTag:'..chat_id,true)
Alert(Company.id,"▪️ قفل  هشتگ (#) فعال شد !")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک: '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockinline:'..chat_id then
if redis:get('Lock:Inline:'..chat_id) then
redis:del('Lock:Inline:'..chat_id)
Alert(Company.id,"▪️ قفل  دکمه شیشه ای ✖️غیرفعال شد ")
else
redis:set('Lock:Inline:'..chat_id,true)
Alert(Company.id,"▪️ قفل  دکمه شیشه ای فعال شد")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک: '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockvideo_note:'..chat_id then
if redis:get('Lock:Video_note:'..chat_id) then
redis:del('Lock:Video_note:'..chat_id)
Alert(Company.id,"▪️ قفل  فیلم سلفی ✖️غیرفعال شد !")
else
redis:set('Lock:Video_note:'..chat_id,true)
Alert(Company.id,"▪️ قفل فیلم سلفی فعال شد !")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک: '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockbot:'..chat_id then
if redis:get('Lock:Bot:'..chat_id) then
redis:del('Lock:Bot:'..chat_id)
Alert(Company.id,"▪️ قفل ورود ربات ✖️غیرفعال شد")
else
redis:set('Lock:Bot:'..chat_id,true)
Alert(Company.id,"▪️ قفل ورود ربات فعال شد")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔️فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔️فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔️فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔️فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔️فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔️فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔️فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔️فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک: '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
----------------------------------------
if cerner == 'groupinfo:'..chat_id then
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
local expire = redis:ttl("ExpireData:"..chat_id)
if expire == -1 then
EXPIRE = "نامحدود"
else
local d = math.floor(expire / day ) + 1
EXPIRE = d.."  روز"
end
-----
local text = '▪️ اطلاعات گروه'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ تاریخ انقضا : '..EXPIRE..'', callback_data = 'cerner'..chat_id}
},{
{text = '▪️ لیست مدیران', callback_data = 'modlist:'..chat_id},{text = '▪️ لیست مالکان', callback_data = 'ownerlist:'..chat_id}
},{
{text = '▪️ لیست فیلتر', callback_data = 'filterlist:'..chat_id},{text = '▪️ لیست سکوت', callback_data = 'silentlist:'..chat_id}
},{
{text = '▪️ لیست مسدود', callback_data = 'Banlist:'..chat_id},{text = '▪️ لیست ویژه', callback_data = 'Viplist:'..chat_id}
},{
{text = '▪️ لینک گروه', callback_data = 'GroupLink:'..chat_id},{text = '▪️ قوانین', callback_data = 'GroupRules:'..chat_id}
},{
{text = '▪️ موقعیت خوشآمد گویی', callback_data = 'update'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'Menu:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'ownerlist:'..chat_id then
local OwnerList = redis:smembers('OwnerList:'..chat_id)
local text = 'لیست مالکان گروه :\n'
for k,v in pairs(OwnerList) do
text = text..k.." - *"..v.."*\n" 
end
text = text.."\n▪️ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBot.." "..Sudoid..""
if #OwnerList == 0 then
text = '▪️ لیست مورد نظر خالی میباشد !'
end
local keyboard = {}
keyboard.inline_keyboard = {{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'Viplist:'..chat_id then
local VipList = redis:smembers('Vip:'..chat_id)
local text = 'لیست ویژه گروه :\n'
for k,v in pairs(VipList) do
text = text..k.." - `"..v.."`\n" 
end
text = text.."\n▪️ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
if #VipList == 0 then
text = '▪️ لیست مورد نظر خالی میباشد !'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️ پاک کردن ', callback_data = 'cleanViplist:'..chat_id}},{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
end
if cerner == 'cleanViplist:'..chat_id then
local text = [[`لیست ویژه` *پاکسازی شد*]]
redis:del('Vip:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '<< بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'modlist:'..chat_id then
local ModList = redis:smembers('ModList:'..chat_id)
local text = 'لیست مدیران گروه :\n'
for k,v in pairs(ModList) do
text = text..k.." - *"..v.."*\n" 
end
text = text.."\n▪️ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
if #ModList == 0 then
text = '▪️ لیست مورد نظر خالی میباشد !'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️ پاک کردن ', callback_data = 'cleanmodlist:'..chat_id}},{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
end
 if cerner == 'Banlist:'..chat_id then
local BanUser = redis:smembers('BanUser:'..chat_id)
local text = 'لیست مسدودیا گروه :\n'
for k,v in pairs(BanUser) do
text = text..k.." - *"..v.."*\n" 
end
text = text.."\n▪️ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
if #BanUser == 0 then
text = '▪️ لیست مورد نظر خالی میباشد !'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text = '▪️ پاک کردن ', callback_data = 'cleanbanlist:'..chat_id}},{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
end
if cerner == 'silentlist:'..chat_id then
 local Silentlist = redis:smembers('MuteUser:'..chat_id)
 local text = 'لیست کاربران سکوت :\n'
 for k,v in pairs(Silentlist) do
 text = text..k.." - *"..v.."*\n" 
 end
text = text.."\n▪️ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
  if #Silentlist == 0 then
text = '▪️ *▪️ لیست مورد نظر خالی میباشد !*'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️ پاک کردن', callback_data = 'cleansilentlist:'..chat_id}},{
{text = '<< بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
 end
 end
if cerner == 'cleanbanlist:'..chat_id then
local text = [[`لیست مسدود` *پاکسازی شد*]]
redis:del('BanUser:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{{text = '<< بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'filterlist:'..chat_id then
 local Filters = redis:smembers('Filters:'..chat_id)
 local text = 'لیست کلمات فیلتر گروه :\n'
 for k,v in pairs(Filters) do
 text = text..k.." - *"..v.."*\n" 
 end
  if #Filters == 0 then
text = '▪️ *▪️ لیست مورد نظر خالی میباشد !*'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '<< بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️ پاک کردن', callback_data = 'cleanFilters:'..chat_id}},{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
 end
 end
if cerner == 'cleanFilters:'..chat_id then
local text = [[`لیست فیلتر` *پاکسازی شد*]]
redis:del('Filters:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'GroupLink:'..chat_id then
local link = redis:get('Link:'..chat_id)
if link then 
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️ حذف لینک ', callback_data = 'Dellink:'..chat_id}},{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,link,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'▪️ *لینک گروه ثبت نشده است*',keyboard)
end
end
if cerner == 'Dellink:'..chat_id then
redis:del('Link:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'▪️ *لینک گروه حذف شد*',keyboard)
end
if cerner == 'GroupRules:'..chat_id then
local rules = redis:get('Rules:'..chat_id)
if rules then 
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '▪️ حذف قوانین ', callback_data = 'Delrules:'..chat_id}},{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,rules,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'▪️ *قوانین گروه ثبت نشده است*',keyboard)
end
end
if cerner == 'Delrules:'..chat_id then
redis:del('Rules:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'▪️ *قوانین گروه حذف شد*',keyboard)
end
---------------------------------------------------------------
if cerner == 'automuteall:'..chat_id then
if redis:get('automuteall'..chat_id) then
redis:del('automuteall'..chat_id)
Alert(Company.id, "▪️ قفل خودکار ✖️غیرفعال شد")
else
redis:set('automuteall'..chat_id,true)
Alert(Company.id, "▪️ قفل خودکار فعال شد")
end
if redis:get('automuteall'..chat_id) then
auto= '✔️فعال'
else
auto= '✖️غیرفعال'
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔️فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔️فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔️فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockflood:'..chat_id then
if redis:get('Lock:Flood:'..chat_id) then
redis:del('Lock:Flood:'..chat_id)
 Alert(Company.id, "▪️ قفل فلود ✖️غیرفعال شد")
else
redis:set('Lock:Flood:'..chat_id,true)
Alert(Company.id, "▪️ قفل فلود فعال شد")
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get('automuteall'..chat_id) then
auto= '✔️فعال'
else
auto= '✖️غیرفعال'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔️فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔️فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔️فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔️فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockspam:'..chat_id then
if redis:get('Spam:Lock:'..chat_id) then
redis:del('Spam:Lock:'..chat_id)
 Alert(Company.id, "▪️ قفل اسپم ✖️غیرفعال شد ")
else
redis:set('Spam:Lock:'..chat_id,true)
Alert(Company.id, "▪️ قفل اسپم فعال شد")
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔️فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔️فعال'
else
spam = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔️فعال'
else
auto= '✖️غیرفعال'
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔️فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockcommand:'..chat_id then
if redis:get('Lock:Cmd'..chat_id) then
redis:del('Lock:Cmd'..chat_id)
 Alert(Company.id, "▪️ قفل دستورات برای کاربر عادی غیر فعال شد")
else
redis:set('Lock:Cmd'..chat_id,true)
Alert(Company.id, "▪️ قفل دستورات برای کاربر عادی فعال شد")
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'muteall:'..chat_id then
if redis:get('MuteAll:'..chat_id) then
redis:del('MuteAll:'..chat_id)
 Alert(Company.id, "▪️ قفل گروه ✖️غیرفعال شد")
else
redis:set('MuteAll:'..chat_id,true)
Alert(Company.id, "▪️ قفل گروه فعال شد")
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'MSGMAXup:'..chat_id then
if tonumber(MSG_MAX) == 15 then
Alert(Company.id,'حداکثر مقدار 15' ,true)
else
MSG_MAX = (redis:get('Flood:Max:'..chat_id) or 6)
MSG_MAX = tonumber(MSG_MAX) + 1
Alert(Company.id,MSG_MAX)
redis:set('Flood:Max:'..chat_id,MSG_MAX)
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'MSGMAXdown:'..chat_id then
if tonumber(MSG_MAX) == 3 then
Alert(Company.id,'حداکثر مقدار 3' ,true)
else
MSG_MAX = (redis:get('Flood:Max:'..chat_id) or 6)
MSG_MAX = tonumber(MSG_MAX) - 1
Alert(Company.id,MSG_MAX)
redis:set('Flood:Max:'..chat_id,MSG_MAX)
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'TIMEMAXup:'..chat_id then
if tonumber(TIME_CHECK) == 9 then
Alert(Company.id,'حداکثر مقدار 9')
else
TIME_CHECK = (redis:get('Flood:Time:'..chat_id) or 2)
TIME_CHECK = tonumber(TIME_CHECK) + 1
Alert(Company.id,TIME_CHECK)
redis:set('Flood:Time:'..chat_id,TIME_CHECK)
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'TIMEMAXdown:'..chat_id then
if tonumber(TIME_CHECK) == 2 then
Alert(Company.id,'حداکثر مقدار 2' ,true)
else
TIME_CHECK = (redis:get('Flood:Time:'..chat_id) or 2)
TIME_CHECK = tonumber(TIME_CHECK) - 1
Alert(Company.id,TIME_CHECK)
redis:set('Flood:Time:'..chat_id,TIME_CHECK)
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'CHMAXup:'..chat_id then
if tonumber(CH_MAX) == 4096 then
Alert(Company.id,'حداکثر مقدار 4096' ,true)
else
CH_MAX = (redis:get('NUM_CH_MAX:'..chat_id) or 200)
CH_MAX= tonumber(CH_MAX) + 50
Alert(Company.id,CH_MAX)
redis:set('NUM_CH_MAX:'..chat_id,CH_MAX)
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'CHMAXdown:'..chat_id then
if tonumber(CH_MAX) == 50 then
Alert(Company.id,'حداکثر مقدار 50' ,true)
else
CH_MAX = (redis:get('NUM_CH_MAX:'..chat_id) or 200)
CH_MAX= tonumber(CH_MAX) - 50
Alert(Company.id,CH_MAX)
redis:set('NUM_CH_MAX:'..chat_id,CH_MAX)
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg"  then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'floodstatus:'..chat_id then
local hash = redis:get('Flood:Status:'..chat_id)
if hash then
if redis:get('Flood:Status:'..chat_id) == 'kickuser' then
redis:set('Flood:Status:'..chat_id,'muteuser')
Status = 'سکوت کاربر'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
elseif redis:get('Flood:Status:'..chat_id) == 'muteuser' then
redis:set('Flood:Status:'..chat_id,'deletemsg')
Status = 'حذف پیام'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
elseif redis:get('Flood:Status:'..chat_id) == 'deletemsg' then
redis:del('Flood:Status:'..chat_id)
Status = 'تنظیم نشده'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
end
else
redis:set('Flood:Status:'..chat_id,'kickuser')
Status = 'اخراج کاربر'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
end
if redis:get("Mute:All:Status:"..chat_id) then
if redis:get("Mute:All:Status:"..chat_id) == "Restricted" then
Statusm = 'Restricted'
elseif redis:get("Mute:All:Status:"..chat_id) == "deletemsg" then
Statusm = 'حذف پیام'
end
else
Statusm = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = '✔فعال'
else
flood = '✖️غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = '✔فعال'
else
spam = '✖️غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = '✔فعال'
else
muteall = '✖️غیرفعال' 
end
if redis:get('automuteall'..chat_id) then
auto= '✔فعال'
else
auto= '✖️غیرفعال'
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg" then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = '✔فعال'
else
cmd = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 4`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '▪️ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ▪️ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ▪️ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '▪️ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ▪️ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '▪️ قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '▪️ موقعیت قفل گروه : '..Statusm..'', callback_data = 'update'..chat_id}
},{
{text = '▪️ قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '▪️ قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
------------------------------------------------------
end --Alert not mod
end --Alert CerNer
-----------------End Mod---------------
----------------Start Owner ----------------------
if not is_Owner(chat_id,Company.from.id) then
Alert(Company.id,'▪️ کاربر '..msg.user_first..' شما دسترسی کافی ندارید')
else
if cerner == 'cleanmodlist:'..chat_id then
local text = [[`لیست مدیران`  *پاکسازی شد*]]
redis:del('ModList:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '<< بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockpin'..chat_id then
if redis:get('Lock:Pin:'..chat_id) then
redis:del('Lock:Pin:'..chat_id)
Alert(Company.id, "▪️ قفل سنجاق ✖️غیرفعال شد !")
else
redis:set('Lock:Pin:'..chat_id,true)
Alert(Company.id, "▪️ قفل  سنجاق فعال  شد ً!")
end
if redis:get('Lock:Link'..chat_id) then
link = '✔فعال'
else
link = '✖️غیرفعال' 
end
if redis:get('Lock:Tag:'..chat_id) then
tag = '✔فعال'
else
tag = '✖️غیرفعال' 
end
if redis:get('Lock:HashTag:'..chat_id) then
hashtag = '✔فعال'
else
hashtag = '✖️غیرفعال' 
end
if redis:get('Lock:Edit'..chat_id) then 
edit = '✔فعال'
else
edit = '✖️غیرفعال'
end
if redis:get('Lock:Inline:'..chat_id) then
inline = '✔فعال'
else
inline = '✖️غیرفعال' 
end
if redis:get('Lock:Video_note:'..chat_id) then
video_note = '✔فعال'
else
video_note = '✖️غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = '✔فعال'
else
bot = '✖️غیرفعال' 
end
if redis:get('Lock:Markdown:'..chat_id) then
markdown = '✔فعال'
else
markdown = '✖️غیرفعال' 
end
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔فعال'
else
pin = '✖️غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = '✔فعال'
else
TD = '✖️غیرفعال'
end
local text = '`▪️ تنظیمات گروه  صفحه : 1`'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '▪️لینک: '..link..'', callback_data = 'lock link:'..chat_id}
},{
{text = '▪️ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '▪️فراخوانی : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id}
},{
{text = '▪️نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '▪️تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id}
},{
{text = '▪️دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '▪️فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id}
},{
{text = '▪️سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '▪️ربات : '..bot..'', callback_data = 'lockbot:'..chat_id}
},{
{text = '>> صفحه بعدی', callback_data = 'pagenext:'..chat_id}
},{
{text = '<< بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
-----------------------
end -- Alert not Owner
-----------------
if msg.message and msg.message.date < tonumber(MsgTime) then
print('OLD MESSAGE')
 return false
end
end
end
end
end
end
return Running()

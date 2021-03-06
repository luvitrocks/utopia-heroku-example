require('response-methods')

local Buffer = require('buffer').Buffer
local Utopia = require('utopia')
local _ = require('utopia-route')
local cors = require('cors')
local logger = require('logger')
local requestQuery = require('request-query')
local bodyParser = require('body-parser')
local fileType = require('file-type')

local app = Utopia:new()
local port = process.env.PORT or 8080

local demoAPI = _.get('/demo', function (req, res)
  res:finish('demo!')
end)

local itemsAPI = _.get('/items/:id', function (req, res)
  res:finish('Requested item with id: ' .. req.params.id)
end)

local nestedAPI = _.get('/items/:id/:foo', function (req, res)
  res:finish('id: ' .. req.params.id .. ' foo: ' .. req.params.foo)
end)

local jsonAPI = _.get('/json/:type', function (req, res)
  if req.params.type == 'array' then
    res:json({1, 2, {a = 'b'}})
  else
    res:json({json = true, foo = 'bar'})
  end
end)

local postAPI = _.post('/post', function (req, res)
  res:json({success = true, body = req.body})
end)

local htmlAPI = _.get('/html', function (req, res)
  res:status(201):send('<h1>Boo</h1>')
end)

local redirectAPI = _.get('/redirect', function (req, res)
  res:redirect('/html')
end)

local bufferAPI = _.post('/buffer', function (req, res)
  local fileTypeData = fileType(req.body)

  if fileTypeData then
    local chunk = req.body:toString()

    res:setHeader('Content-Type', fileTypeData.mime)
    res:status(201):finish(chunk)
  else
    res:sendStatus(400)
  end
end)

local rawBufferAPI = _.post('/buffer-raw', function (req, res)
  res:status(201):send(req.body)
end)

local sendStatusAPI = _.get('/status', function (req, res)
  res:sendStatus(401)
end)

app:use(logger('short'))
app:use(cors())
app:use(requestQuery)
app:use(bodyParser.raw())
app:use(bodyParser.text())
app:use(bodyParser.json())
app:use(bodyParser.urlencoded())
app:use(jsonAPI)
app:use(postAPI)
app:use(demoAPI)
app:use(itemsAPI)
app:use(nestedAPI)
app:use(htmlAPI)
app:use(redirectAPI)
app:use(bufferAPI)
app:use(rawBufferAPI)
app:use(sendStatusAPI)
app:use(function (req, res, nxt)
  res:finish('done')
end)

app:listen(port)
print('server is running on ' .. port)

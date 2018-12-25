local json = require "json"


return function (err)
	if not ngx then 
		print(err .. "\n" .. debug.traceback())
		return
	end

	if err then
		if type(err) == "table" then
			ngx.log(ngx.ERR, json.encode(err) .. "\n" .. debug.traceback())
		else
			ngx.log(ngx.ERR, err .. "\n" .. debug.traceback())
		end
	else
		ngx.log(ngx.ERR, "\n" .. debug.traceback())
	end
end
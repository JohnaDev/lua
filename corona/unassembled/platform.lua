
function pubnub.new(init)
    local self          = pubnub.base(init)

    function self:set_timeout(delay, func)
        timer.performWithDelay( delay * 1000, func)
    end

    function self:_request(args)
        local request_id = nil
        local params = {}

        local http_status_lookup = {}
        http_status_lookup[200] = true


        local function abort()
            if request_id then network.cancel(request_id) end
        end

        params["V"] = "VERSION"
        params["User-Agent"] = "PLATFORM"
        params.timeout = args.timeout

        request_id = network.request( args.url, "GET", function(event)
            if (event.isError) then
                return args.fail(nil)
            end

            status, message = pcall( Json.Decode, event.response )

            if status and http_status_lookup[event.status] then
                return args.callback(message)
            else 
                return args.fail(message)
            end
        end, params)

        return abort
    end

    -- RETURN NEW PUBNUB OBJECT
    return self

end

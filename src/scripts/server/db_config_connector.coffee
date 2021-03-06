zmq = require "zmq"
fs = require "fs"
protobuf = require "node-protobuf"
log = require "loglevel"

Config = require "./config"
Const = require "./constants"
FieldData = require "./fieldData"
ServiceConfig = require "./svcconfig_connector"

require("source-map-support").install()
log.setLevel "debug"

dbConfigProto = new protobuf(fs.readFileSync("proto/db_config.pb.desc"))

class DBConfig

    @addTable: (provider, tableMeta) =>
        log.debug "Adding table: #{tableMeta.Name} of provider: #{provider} to the db config"
        connection = DBConfigConnection.getConnection(Config.Values.DB_CONFIG_SERVICE)
        connection.sendServerConfig provider, tableMeta
        return


module.exports = DBConfig

class DBConfigConnection

    @_configService = ServiceConfig.getInstance()

    @getConnection: (service) ->
        addresses = @_configService.getAddresses service
        try
            dbConfigAddress = addresses[Const.ENDPOINT_TYPE.DB_CONFIG][Const.SOCKET_TYPE.PUSH_PULL][0]
        catch ex
            log.error "Couldn't find addresses for db config: #{service}!"
            throw ex
        return new DBConfigConnection(dbConfigAddress)

    _pushPullSocket: null

    constructor: (@dbConfigAddress) ->

    sendServerConfig: (provider, tableMeta) =>

        @_pushPullSocket = zmq.socket(Const.ZMQ_PUSH)
        @_pushPullSocket.connect(@dbConfigAddress)

        tableMeta.Schema ?= ""
        serverConfigMessage =
            Type: Const.SERVER_CONFIG_TYPE
            Name: provider
            Tables: [tableMeta]
        @_pushPullSocket.send dbConfigProto.serialize serverConfigMessage, "virtdb.interface.pb.ServerConfig"

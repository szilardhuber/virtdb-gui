class Requests

    _address: null
    _providerName: null

    constructor: (@_address) ->

    setDataProvider: (@_providerName) =>

    _endpoints: '/api/endpoints'

    _dataProviderMetaDataTableNames: '/api/data_provider/{0}/meta_data/table_names'
    _dataProviderMetaDataTable: '/api/data_provider/{0}/meta_data/table/{1}'
    _dataProviderDataTable: '/api/data_provider/{0}/data/table/{1}/count/{2}'
    _dataProviderDataTableField: '/api/data_provider/{0}/data/table/{1}/field/{2}/count/{3}'

    _dbConfig: 'api/db_config'

    endpoints: () =>
        return @_address + @_endpoints

    metaDataTableNames: () =>
        return @_address + formatString(@_dataProviderMetaDataTableNames, @_providerName)

    metaDataTable: (table) =>
        return @_address + formatString(@_dataProviderMetaDataTable, @_providerName, table)

    dataTable: (table, count) =>
        return @_address + formatString(@_dataProviderDataTable, @_providerName, table, count)

    dataTableField: (table, field, count) =>
        return @_address + formatString(@_dataProviderDataTableField, @_providerName, table, field, count)

    dbConfig: () =>
        return @_address + @_dbConfig

    formatString = (format, args...) =>
        return format.replace /{(\d+)}/g, (match, number) ->
          return if typeof args[number] != 'undefined' then args[number] else match

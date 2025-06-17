%dw 2.0
var table = "TODO"
var inputPayload = vars.inputPayload
var inputAttributes = vars.inputAttributes
var readyStatus = "TODO"

fun cleanTimestamp(ts: String): String =
  ts replace "Z" with ""

fun safeString(str, fallback) =
  "COALESCE(NULLIF('$(str default "")', ''), $(fallback))"

fun safeBoolean(b, fallback) =
  "COALESCE($(if (b != null)
    (b as Boolean as String)
  else
    "null"), $(fallback))"

fun safeArray(arr, fallback) = do {
  var arrItems = if (arr != null and !isEmpty(arr)) (((arr filter (i) -> i != null) map (i) -> "'$(i)'") joinBy ",") as String else ''
  ---
  "COALESCE($(
    if (arr == null)
        'null'
    else
        'ARRAY[$(arrItems)]'
    ), $(fallback))"
}

fun safeTimestamp(ts, fallback) =
  "COALESCE($(if ((ts default "") == "")
    "null"
  else
    "PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%S.%3E', '$(cleanTimestamp(ts))')"), $(fallback))"

fun safeNumber(n, fallback) =
  "COALESCE($(if (n != null)
    (n as String)
  else
    "null"), $(fallback))"
var readyStatusFilter = if (readyStatus != "")
  " AND requestPayload LIKE '%{\"key\": \"newStatus\",\"value\": \"$(readyStatus)\"}%'"
else
  ""
output application/json  
---
"UPDATE `$(table)` AS T SET
T.transactionId=$(safeString(inputPayload.transactionId, "T.transactionId")),
T.requestPayload=$(safeString(inputPayload.requestPayload, "T.requestPayload")),
T.requestUserProperties=$(safeString(inputPayload.requestUserProperties, "T.requestUserProperties")),
T.errorMessage=$(safeString(inputPayload.errorMessage, "T.errorMessage")),
T.warningMessage=$(safeString(inputPayload.warningMessage, "T.warningMessage")),
T.eventClass=$(safeString(inputPayload.eventClass, "T.eventClass")),
T.eventType=$(safeString(inputPayload.eventType, "T.eventType")),
T.queueName=$(safeString(inputPayload.queueName, "T.queueName")),
T.lastModifiedDate=$(safeTimestamp(inputPayload.lastModifiedDate, "T.lastModifiedDate")),
T.toBeReprocessed=$(safeBoolean(inputPayload.toBeReprocessed, "T.toBeReprocessed")),
T.numberOfRetries=$(safeNumber(inputPayload.numberOfRetries, "T.numberOfRetries")),
T.successfulActions=$(safeArray(inputPayload.successfulActions, "T.successfulActions")),
T.failedActions=$(safeArray(inputPayload.failedActions, "T.failedActions")),
T.notExecutedActions=$(safeArray(inputPayload.notExecutedActions, "T.notExecutedActions")),
T.orderNumber=$(safeString(inputPayload.orderNumber, "T.orderNumber")),
T.shipmentOrderNumber=$(safeString(inputPayload.shipmentOrderNumber, "T.shipmentOrderNumber")),
T.omsShipmentNumber=$(safeString(inputPayload.omsShipmentNumber, "T.omsShipmentNumber")),
T.shipmentHeld=$(safeBoolean(inputPayload.shipmentHeld, "T.shipmentHeld")),
T.eventTimestamp=$(safeTimestamp(inputPayload.eventTimestamp, "T.eventTimestamp"))
WHERE T.orderNumber='$(inputAttributes.queryParams.orderNumber default "")'
AND T.shipmentHeld=$(inputAttributes.queryParams.shipmentHeld as String)$(readyStatusFilter);" replace "\n" with " "
%dw 2.0
output application/json

var tlg_wms = "modadj"

---
(payload.wms.name filterObject((value, key, index) -> key ~= tlg_wms))[tlg_wms] default tlg_wms
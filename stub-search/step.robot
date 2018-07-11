*** Settings ***
Library  Collections
Library  RequestsLibrary
Suite Setup  Create all Session

*** Variables ***
${SEARCH_SERVICE}  ${EMPTY}
${PRODUCT_SERVICE}  ${EMPTY}
${BASKET_SERVICE}  ${EMPTY}
${ORDER_SERVICE}  ${EMPTY}

*** Testcases ***
Order two products
  ${selected_product_id}=  Search product : Nike
  Log To Console   ${selected_product_id}
  Show selected Nike product   ${selected_product_id}
  ${basket_id}=  Add first product
  Log To Console   ${basket_id}
#   Show second selected Nike product
  Add second product  ${basket_id}
  Check basket detail  ${basket_id}
  Submit Order  ${basket_id}
  
*** Keywords ***
Create all Session
  Create Session  ${SEARCH_SERVICE}  http://localhost:8882
  Create Session  ${PRODUCT_SERVICE}  http://localhost:8882
  Create Session  ${BASKET_SERVICE}  http://localhost:8882
  Create Session  ${ORDER_SERVICE}  http://localhost:8882

Search product : Nike

  ${response}=  Get Request   ${SEARCH_SERVICE}   /search?q=nike
  Should Be Equal    ${response.status_code}    ${200}
  ${size}=  Get Length    ${response.json()['product']}
  Should Be Equal    ${size}    ${2}
  [Return]   ${response.json()['product'][0]['product_id']}

Show selected Nike product
  [Arguments]  ${product_id}
  ${response}=  Get Request   ${PRODUCT_SERVICE}   /products/${product_id}
  Should Be Equal    ${response.status_code}    ${200}
  Log    ${response.json()['product_name']}

Add first product
  ${headers}=   Create Dictionary  Content-Type=application/json 
  ${datas}=  Create Dictionary
  ...  product_id=${238}
  ...  product_name=Nike A100
  ...  product_price=${2600}
  ...  product_desc=New nike 20158
  ...  quantity=${1}
  ${response}=  Post Request  ${BASKET_SERVICE}  /baskets  headers=${headers}  data=${datas}
  Should Be Equal    ${response.status_code}    ${200}
  [Return]   ${response.json()['basket_id']}

Add second product
  [Arguments]  ${basket_id}
  ${headers}=   Create Dictionary  Content-Type=application/json 
  ${datas}=  Create Dictionary
  ...  product_id=${100}
  ...  product_name=Nike A200
  ...  product_price=${1600}
  ...  product_desc=New nike 20150
  ...  quantity=${1}
  ${response}=  Post Request  ${BASKET_SERVICE}  /baskets/${basket_id}  headers=${headers}  data=${datas}
  Should Be Equal    ${response.status_code}    ${200}

Check basket detail
  [Arguments]  ${basket_id}
  ${response}=  Get Request   ${BASKET_SERVICE}   /baskets/${basket_id}
  Should Be Equal    ${response.status_code}    ${200}
  ${size}=  Get Length    ${response.json()['product']}
  Should Be Equal    ${size}    ${2}

Submit Order
  [Arguments]  ${basket_id}
  ${headers}=   Create Dictionary  Content-Type=application/json 
  ${datas}=  Create Dictionary
  ...  address=addr1
  ...  name=pak pack
  ...  date_order=11/07/18
  ...  time=23:40
  ...  payment_method=Cash on delivery
  ${response}=  Post Request  ${ORDER_SERVICE}  /orders/${basket_id}  headers=${headers}  data=${datas}
  Should Be Equal    ${response.status_code}    ${200}
  Log To Console  ${response.json()['invoice_no']}
  Log To Console  ${response.json()['total_amt']}
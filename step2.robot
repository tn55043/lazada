*** Settings ***
Library  Collections
Library  RequestsLibrary

*** Variables ***

*** Testcases ***
Order 1 product
  ${nike1}=  Search product : nike
  Show detail of nike no  ${nike1}
  ${basket_id}=  Add product no 1  ${nike1}
  Check basket  ${basket_id}
  Order and payment  ${basket_id}
  
*** Keywords ***
Search product : nike
  Create Session  search  http://localhost:8882
  ${result}=  Get Request  search  /search?q=nike
  Should Be Equal  ${result.status_code}  ${200}
  ${size}=  Get Length  ${result.json()['product']}
  Should Be Equal  ${size}  ${2}
  Should Be Equal  ${result.json()['product'][0]['product_id']}  ${238}
  Should Be Equal  ${result.json()['product'][1]['product_id']}  ${100}
  [Return]  ${result.json()['product'][0]['product_id']}

Show detail of nike no
  [Arguments]  ${id}
  Create Session  product  http://localhost:8882
  ${result}=  Get Request  product  /products/${id}
  Should Be Equal  ${result.status_code}  ${200}

Add product no 1
  [Arguments]  ${id}
  Create Session  baskets  http://localhost:8882
  ${header}=  Create Dictionary  Content-Type=application/json
  ${product}=  Create Dictionary
  ...  product_id=${id}
  ...  product_name=Nike A100
  ...  product_price=${2600}
  ...  product_desc=New nike 20158
  ...  quantity=${1}
  ${result}=  Post Request  baskets  /baskets  data=${product}  headers=${header}
  Should Be Equal  ${result.status_code}  ${200}
  [Return]  ${result.json()['basket_id']}

Check basket
  [Arguments]  ${basket_id}
  Create Session  baskets  http://localhost:8882
  ${result}=  Get Request  baskets  /baskets/${basket_id}
  Should Be Equal  ${result.status_code}  ${200}

Order and payment
  [Arguments]  ${basket_id}
  Create Session  orders  http://localhost:8882
  ${header}=  Create Dictionary  Content-Type=application/json
  ${order}=  Create Dictionary
  ...  address=addr1
  ...  name=pak pack
  ...  date_order=11/07/18
  ...  time=23:40
  ...  payment_method=Cash on delivery
  ${result}=  Post Request  orders  /orders/${basket_id}  data=${order}  headers=${header}
  Should Be Equal  ${result.status_code}  ${200}
  Should Be Equal  ${result.json()['invoice_no']}  49534523475
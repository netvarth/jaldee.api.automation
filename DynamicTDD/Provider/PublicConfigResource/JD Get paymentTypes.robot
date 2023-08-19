*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Customer
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-Get paymentTypes-1
       [Documentation]   Provider check to Get paymentTypes without login
       ${resp}=  Get paymentTypes
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]}   cash
       Should Be Equal As Strings    ${resp.json()[1]}   credit cards 
       Should Be Equal As Strings    ${resp.json()[2]}   debit cards
       Should Be Equal As Strings    ${resp.json()[3]}   net banking
       Should Be Equal As Strings    ${resp.json()[4]}   upi
       Should Be Equal As Strings    ${resp.json()[5]}   wallets
       
JD-TC-Get paymentTypes -2
       [Documentation]   Provider check to Get paymentTypes provider login
       ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get paymentTypes
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]}   cash
       Should Be Equal As Strings    ${resp.json()[1]}   credit cards 
       Should Be Equal As Strings    ${resp.json()[2]}   debit cards
       Should Be Equal As Strings    ${resp.json()[3]}   net banking
       Should Be Equal As Strings    ${resp.json()[4]}   upi
       Should Be Equal As Strings    ${resp.json()[5]}   wallets
             
JD-TC-Get paymentTypes -3
       [Documentation]   Provider check to Get paymentTypes consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get paymentTypes
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]}   cash
       Should Be Equal As Strings    ${resp.json()[1]}   credit cards 
       Should Be Equal As Strings    ${resp.json()[2]}   debit cards
       Should Be Equal As Strings    ${resp.json()[3]}   net banking
       Should Be Equal As Strings    ${resp.json()[4]}   upi
       Should Be Equal As Strings    ${resp.json()[5]}   wallets      
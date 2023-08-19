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

JD-TC-Get parkingTypes-1
       [Documentation]   Provider check to Get parkingTypes without login
       ${resp}=  Get parkingTypes
       Should Be Equal As Strings    ${resp.status_code}   200 
       Should Be Equal As Strings    ${resp.json()[0]}   None
       Should Be Equal As Strings    ${resp.json()[1]}   Free 
       Should Be Equal As Strings    ${resp.json()[2]}   Street
       Should Be Equal As Strings    ${resp.json()[3]}   Privatelot
       Should Be Equal As Strings    ${resp.json()[4]}   Valet
       Should Be Equal As Strings    ${resp.json()[5]}   Paid

JD-TC-Get parkingTypes -2
       [Documentation]   Provider check to Get parkingTypes provider login
       ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get parkingTypes
       Should Be Equal As Strings    ${resp.status_code}   200       
       Should Be Equal As Strings    ${resp.json()[0]}   None
       Should Be Equal As Strings    ${resp.json()[1]}   Free 
       Should Be Equal As Strings    ${resp.json()[2]}   Street
       Should Be Equal As Strings    ${resp.json()[3]}   Privatelot
       Should Be Equal As Strings    ${resp.json()[4]}   Valet
       Should Be Equal As Strings    ${resp.json()[5]}   Paid
                   
JD-TC-Get parkingTypes -3
       [Documentation]   Provider check to Get parkingTypes consumer login
       ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Get parkingTypes
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings    ${resp.json()[0]}   None
       Should Be Equal As Strings    ${resp.json()[1]}   Free 
       Should Be Equal As Strings    ${resp.json()[2]}   Street
       Should Be Equal As Strings    ${resp.json()[3]}   Privatelot
       Should Be Equal As Strings    ${resp.json()[4]}   Valet
       Should Be Equal As Strings    ${resp.json()[5]}   Paid
       

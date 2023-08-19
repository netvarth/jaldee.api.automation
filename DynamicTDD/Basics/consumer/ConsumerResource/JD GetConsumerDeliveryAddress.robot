*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Consumer Delivery Address
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Test Cases ***

JD-TC-GetConsumerDeliveryAddress-1
    [Documentation]    Get consumer delivery address.

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.ynwtest@netvarth.com
    ${city}=   get_place
    ${address}=  get_address
    ${landmark}=   FakerLibrary.sentence
    ${postcode}=  FakerLibrary.postcode

    ${resp}=   Update Consumer Delivery Address    ${CUSERNAME10}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Consumer Delivery Address   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumber']}             ${CUSERNAME10} 
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}               ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}                ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['email']}                   ${email} 
    Should Be Equal As Strings  ${resp.json()[0]['address']}                 ${address}
    Should Be Equal As Strings  ${resp.json()[0]['city']}                    ${city}
    Should Be Equal As Strings  ${resp.json()[0]['postalCode']}              ${postcode}
    Should Be Equal As Strings  ${resp.json()[0]['landMark']}                ${landmark}
    
JD-TC-GetConsumerDeliveryAddress-2
    [Documentation]    Get consumer delivery address with another phone number..  
   
    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${new_no}=  Evaluate  ${CUSERNAME21}+257831
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME11}.ynwtest@netvarth.com
    ${city}=   get_place
    ${address}=  get_address
    ${landmark}=   FakerLibrary.sentence
    ${postcode}=  FakerLibrary.postcode

    ${resp}=   Update Consumer Delivery Address    ${new_no}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Consumer Delivery Address   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumber']}             ${new_no} 
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}               ${firstname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}                ${lastname}
    Should Be Equal As Strings  ${resp.json()[0]['email']}                   ${email} 
    Should Be Equal As Strings  ${resp.json()[0]['address']}                 ${address}
    Should Be Equal As Strings  ${resp.json()[0]['city']}                    ${city}
    Should Be Equal As Strings  ${resp.json()[0]['postalCode']}              ${postcode}
    Should Be Equal As Strings  ${resp.json()[0]['landMark']}                ${landmark}

JD-TC-GetConsumerDeliveryAddress-3
    [Documentation]    Get consumer delivery address with provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Consumer Delivery Address   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      []


JD-TC-GetConsumerDeliveryAddress-UH1
    [Documentation]    Get consumer delivery address without login.

    ${resp}=   Get Consumer Delivery Address   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"







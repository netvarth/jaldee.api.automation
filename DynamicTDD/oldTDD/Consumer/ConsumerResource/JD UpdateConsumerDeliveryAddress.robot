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

*** Variables ***
${CUSERPH}      ${CUSERNAME}

*** Test Cases ***

JD-TC-UpdateConsumerDeliveryAddress-1
      [Documentation]    Update consumer delivery address.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-UpdateConsumerDeliveryAddress-2
      [Documentation]    Update consumer delivery address with another phone number.

      ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${new_no}=  Evaluate  ${CUSERNAME21}+257831
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${new_no}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateConsumerDeliveryAddress-3
      [Documentation]    Update consumer delivery address without landmark.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateConsumerDeliveryAddress-4
      [Documentation]    Update consumer delivery address by two times with he same details.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateConsumerDeliveryAddress-5
      [Documentation]    Update consumer delivery address with provider's phone number.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${PUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateConsumerDeliveryAddress-7
      [Documentation]    Update consumer delivery address with same  name and address as consumer have.

      ${CUSERPH0}=  Evaluate  ${CUSERPH}+1428541
      Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
      ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${address}=  FakerLibrary.address
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Activation  ${CUSERPH0}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateConsumerDeliveryAddress-8
      [Documentation]    Update consumer delivery address with provider login.
    
      ${resp}=  Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${CONSUMER_NOT_EXIST}"

JD-TC-UpdateConsumerDeliveryAddress-UH1
      [Documentation]    Update consumer delivery address without first name.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${EMPTY}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${PROVIDE_FIRST_NAME}"

JD-TC-UpdateConsumerDeliveryAddress-UH2
      [Documentation]    Update consumer delivery address without last name.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${EMPTY}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${PROVIDE_LAST_NAME}"


JD-TC-UpdateConsumerDeliveryAddress-UH3
      [Documentation]    Update consumer delivery address without email.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${EMPTY}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${INVALID_EMAIL_FOR_DELIVERY_ADDRESS}"

JD-TC-UpdateConsumerDeliveryAddress-UH4
      [Documentation]    Update consumer delivery address without giving city.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${EMPTY}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${PROVIDE_CITY_NAME}"

JD-TC-UpdateConsumerDeliveryAddress-UH5
      [Documentation]    Update consumer delivery address without postal code.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${EMPTY}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${PROVIDE_POSTAL_CODE}"

JD-TC-UpdateConsumerDeliveryAddress-UH6
      [Documentation]    Update consumer delivery address without address.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${EMPTY}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${PROVIDE_ADDRESS}"

JD-TC-UpdateConsumerDeliveryAddress-UH7
      [Documentation]    Update consumer delivery address with invalid phone number.

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    01253    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${INVALID_PHONE_FOR_DELIVERY_ADDRESS}"

JD-TC-UpdateConsumerDeliveryAddress-UH8
      [Documentation]    Update consumer delivery address without login.

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode

      ${resp}=   Update Consumer Delivery Address    ${CUSERNAME20}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"



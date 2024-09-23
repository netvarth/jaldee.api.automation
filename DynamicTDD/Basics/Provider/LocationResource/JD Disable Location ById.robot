*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${queue1}   Morning queue
${queue2}   Evening queue
${SERVICE1}	   Bridal MakeupW1

*** Test Cases ***

JD-TC-DisableLocation-1
      [Documentation]  Disable a location by provider login and check the corresponding queues are disabled

      ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+450001
      
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_D}=  Provider Signup  PhoneNumber=${PUSERNAME_D}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_D}

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}      
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}

      ${resp}=   Get Service
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}

      ${resp}=  Sample Queue  ${lid}   ${p1_s1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}

      ${resp}=  Get Queue ById  ${q_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED

      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Queue ById  ${q_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED


JD-TC-DisableLocation-2
      [Documentation]  Disable a location by provider login and check the corresponding schedules are disabled

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}

      ${resp}=   Get Service
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}

      ${resp}=  Create Sample Schedule   ${lid}   ${p1_s1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${sch_id}  ${resp.json()}

      ${resp}=  Get Appointment Schedule ById  ${sch_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['apptState']}  ENABLED

      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Appointment Schedule ById  ${sch_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  apptState


JD-TC-DisableLocation-3
      [Documentation]  Disable a location by admin user login

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User  admin=${bool[1]}

      ${resp}=    Provider Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data     
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-DisableLocation-UH1

      [Documentation]  Disable a location which is already disabled
     
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  ${resp.json()}  ${LOCATION_ALREADY_DISABLED}

JD-TC-DisableLocation-UH2

      [Documentation]  Disable a location of another provider
      ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+450003
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_G}=  Provider Signup  PhoneNumber=${PUSERNAME_G}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_G}

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data     
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  ${resp.json()}  ${NO_PERMISSION}


JD-TC-DisableLocation -UH3

      [Documentation]   Provider disable a location without login  
      
      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-DisableLocation -UH4

      [Documentation]   Consumer disable a location

      ${account_id}=    get_acc_id       ${PUSERNAME_G}
      ${NewCustomer}  ${token}  Create Sample Customer  ${account_id}

      ${resp}=    ProviderConsumer Login with token   ${NewCustomer}  ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-DisableLocation-UH5

      [Documentation]  Disable base location

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid1}  ${resp.json()[0]['id']}

      ${resp}=  Disable Location  ${lid1}
      Should Be Equal As Strings    ${resp.status_code}   422
      Should Be Equal As Strings  ${resp.json()}  ${BASE_LOCATION_CANNOT_BE_DISABLED}


JD-TC-DisableLocation-UH6
      [Documentation]  Disable a location by non-admin user login

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User

      ${resp}=    Provider Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid1}  ${resp.json()[1]['id']}

      ${resp}=  Disable Location  ${lid1}
      Should Be Equal As Strings    ${resp.status_code}   422
      # Should Be Equal As Strings  ${resp.json()}  ${BASE_LOCATION_CANNOT_BE_DISABLED}


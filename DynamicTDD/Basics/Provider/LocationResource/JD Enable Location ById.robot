*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/providers.py




*** Test Cases ***
JD-TC-EnableLocation-1
      [Documentation]  Disable and Enable a location
      ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+450015
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_D}=  Provider Signup  PhoneNumber=${PUSERNAME_D}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_D}

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data    
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}

      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['status']}  ${status[1]}

      ${resp}=  Enable Location  ${lid} 
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}


JD-TC-EnableLocation-2
      [Documentation]  Enable a location by provider login and check the corresponding queues are still in disabled state (gets disabled on disabling location)

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

      ${resp}=  Sample Queue  ${lid}   ${p1_s1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${q_id}  ${resp.json()}

      ${resp}=  Get Queue ById  ${q_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}

      ${resp}=   Disable Location  ${lid}  
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['status']}  ${status[1]}

      ${resp}=  Get Queue ById  ${q_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[1]}

      ${resp}=  Enable Location  ${lid}  
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}

      ${resp}=  Get Queue ById  ${q_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[1]}


JD-TC-EnableLocation-UH1
      [Documentation]  Enable an already enabled location 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data    
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}

      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}

      ${resp}=  Enable Location  ${lid}  
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  ${resp.json()}  ${LOCATION_ALREADY_ENABLED}


JD-TC-EnableLocation-UH2
      [Documentation]  Enable a location of another provider

      ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data    
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

      ${resp}=  Disable Location  ${lid}  
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Provider Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login     ${PUSERNAME73}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  Enable Location  ${lid}  
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  ${resp.json()}  ${NO_PERMISSION}

JD-TC-EnableLocation -UH3
      [Documentation]   Provider enable a location without login  
      ${resp}=  Enable Location  ${lid}  
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-EnableLocation -UH4
      [Documentation]   Consumer enable a location
      ${account_id}=    get_acc_id       ${PUSERNAME72}
      ${NewCustomer}  ${token}  Create Sample Customer  ${account_id}

      ${resp}=    ProviderConsumer Login with token   ${NewCustomer}  ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Enable Location  ${lid}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}


*** COMMENTS ***

      

JD-TC-EnableLocation -UH3
       [Documentation]   Provider enable a location without login  
       ${resp}=  Enable Location  ${lid}
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-EnableLocation -UH5
       [Documentation]   Consumer enable a location
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Enable Location  ${lid}
       Should Be Equal As Strings    ${resp.status_code}   401
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
                                                     
JD-TC-VerifyEnableLocation-2
      [Documentation]  Verification of Enable location
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  04s
      ${s_id}=  Create Sample Service  ${SERVICE1}
      ${sTime3}=  add_timezone_time  ${tz}  0  55  
      ${eTime3}=  add_timezone_time  ${tz}  0  60  
      ${sTime4}=  add_timezone_time  ${tz}  1  15  
      ${eTime4}=  add_timezone_time  ${tz}  1  30  
      ${resp}=  Create Queue  ${queue1}  Weekly  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid2}  ${s_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q1}  ${resp.json()}
      ${resp}=  Create Queue  ${queue2}  Weekly  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime4}  ${eTime4}  1  5  ${lid2}  ${s_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q2}  ${resp.json()}
      ${resp}=  Disable Location  ${lid2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      ${resp}=  Get Queue ById  ${q1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
      ${resp}=  Get Queue ById  ${q2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
      ${resp}=  Get Location ById  ${lid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  status=INACTIVE
      ${resp}=  Enable Location  ${lid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  status=ACTIVE
      ${resp}=  Get Queue ById  ${q1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
      ${resp}=  Get Queue ById  ${q2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED

# JD-TC-VerifyEnableLocation-3
#       [Documentation]  Verification of Enable location
#       ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       sleep  04s
#       ${s_id}=  Create Sample Service  ${SERVICE1}
#       ${sTime3}=  add_timezone_time  ${tz}  0  55  
#       ${eTime3}=  add_timezone_time  ${tz}  0  60  
#       ${sTime4}=  add_timezone_time  ${tz}  1  15  
#       ${eTime4}=  add_timezone_time  ${tz}  1  30  
#       ${resp}=  Create Queue  ${queue1}  Weekly  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid8}  ${s_id}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Set Suite Variable  ${q1}  ${resp.json()}
#       ${resp}=  Create Queue  ${queue2}  Weekly  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime4}  ${eTime4}  1  5  ${lid8}  ${s_id}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Set Suite Variable  ${q2}  ${resp.json()}
#       ${resp}=  Disable Location  ${lid8}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       sleep  02s
#       ${resp}=  Get Queue ById  ${q1}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
#       ${resp}=  Get Queue ById  ${q2}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
#       ${resp}=  Get Location ById  ${lid8}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Verify Response  ${resp}  status=INACTIVE
#       ${resp}=  Enable Location  ${lid8}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  Get Location ById  ${lid8}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Verify Response  ${resp}  status=ACTIVE
#       ${resp}=  Get Queue ById  ${q1}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
#       ${resp}=  Get Queue ById  ${q2}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED

JD-TC-VerifyEnableLocation-1
      [Documentation]  Verification of Enable location
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['queueState']}  DISABLED 
      ${resp}=  Enable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  status=ACTIVE
      ${resp}=  Get queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['queueState']}  DISABLED      

JD-TC-EnableLocation-UH1
      [Documentation]  Enable a location which is already enabled
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Enable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_ALREADY_ENABLED}"


*** Keywords ***

Multiple Location
      [Arguments]  ${index}  ${business_conf}
      # ${business_conf}=  json.loads  ${business_conf}
      Set Suite Variable  ${dom}  ${business_conf[${index}]['domain']}
      Set Suite Variable  ${sub_dom}  ${business_conf[${index}]['subDomains'][0]['subDomain']}
      RETURN  ${dom}  ${sub_dom}
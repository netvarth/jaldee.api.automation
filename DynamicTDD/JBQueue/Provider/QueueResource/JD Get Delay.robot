*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Delay
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}     Radio Repdca111

*** Test Cases ***

JD-TC-GetDelay-1
      [Documentation]  Add delay by enabling sendMessage

      ${multilocdoms}=  get_mutilocation_domains
      Log  ${multilocdoms}
      Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
      Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+55102037
      ${highest_package}=  get_highest_license_pkg
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_G}    ${highest_package[0]}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_G}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_G}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_G}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_G}${\n}
      Set Suite Variable  ${PUSERNAME_G}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      
      ${list}=  Create List  1  2  3  4  5  6  7
      ${ph1}=  Evaluate  ${PUSERNAME_G}+15566124
      ${ph2}=  Evaluate  ${PUSERNAME_G}+25566128
      ${views}=  Random Element    ${Views}
      ${name1}=  FakerLibrary.name
      ${name2}=  FakerLibrary.name
      ${name3}=  FakerLibrary.name
      ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
      ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
      ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_G}.${test_mail}  ${views}
      ${bs}=  FakerLibrary.bs
      ${companySuffix}=  FakerLibrary.companySuffix
      # ${city}=   get_place
      # ${latti}=  get_latitude
      # ${longi}=  get_longitude
      # ${postcode}=  FakerLibrary.postcode
      # ${address}=  get_address
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      ${parking}   Random Element   ${parkingType}
      ${24hours}    Random Element    ${bool}
      ${desc}=   FakerLibrary.sentence
      ${url}=   FakerLibrary.url
      ${sTime}=  add_timezone_time  ${tz}  0  15  
      ${eTime}=  add_timezone_time  ${tz}  0  45 
      ${DAY1}=  db.get_date_by_timezone  ${tz}

      ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
      Log  ${fields.json()}
      Should Be Equal As Strings    ${fields.status_code}   200

      ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

      ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${spec}=  get_Specializations  ${resp.json()}
      ${resp}=  Update Specialization  ${spec}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Enable Waitlist
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

      ${pid}=  get_acc_id  ${PUSERNAME_G}
    
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  true  true  true  true  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}  ${DAY1}
      ${DAY2}=  db.add_timezone_date  ${tz}  70      
      Set Suite Variable  ${DAY2}  ${DAY2}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}  ${list}
      ${sTime}=  add_timezone_time  ${tz}  4  00  
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}   5  30
      Set Suite Variable   ${eTime}
      # ${city}=   get_place
      # Set Suite Variable  ${city}
      # ${latti}=  get_latitude
      # Set Suite Variable  ${latti}
      # ${longi}=  get_longitude
      # Set Suite Variable  ${longi}
      # ${postcode}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode}
      # ${address}=  get_address
      # Set Suite Variable  ${address}
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      Set Suite Variable  ${city}
      Set Suite Variable  ${latti}
      Set Suite Variable  ${longi}
      Set Suite Variable  ${postcode}
      Set Suite Variable  ${address}
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}
      ${s_id1}=  Create Sample Service  ${SERVICE1}
      Set Suite Variable  ${s_id1}
      ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  3  30  
      Set Suite Variable   ${eTime1}
      ${queue_name}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid}  ${resp.json()}
      ${delay_time}=   Random Int  min=5   max=40
      ${desc}=   FakerLibrary.word
      ${resp}=  Add Delay  ${qid}  ${delay_time}  ${desc}  ${bool[1]} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=${delay_time}
      ${resp}=  Add Delay  ${qid}  0  ${desc}  ${bool[1]} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Delay  ${qid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  delayDuration=0

JD-TC-GetDelay-UH1
    [Documentation]  Get delay using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetDelay-UH2
    [Documentation]  Get delay without login
    ${resp}=  Get Delay  ${qid} 
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetDelay-UH3
    [Documentation]  Get delay of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue  ${PUSERNAME1}
    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Get Delay  ${qid} 
    Log  ${resp.json()} 
    Verify Response  ${resp}  delayDuration=0
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-Communication Between Provider And Consumer-1
	[Documentation]   Communication between provider and consumer after waitlist operation


    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_P}=  Evaluate  ${PUSERNAME}+55668442
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_P}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_P}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_P}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_P}${\n}
    Set Suite Variable  ${PUSERNAME_P}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${a_id}  ${decrypted_data['id']}
    # Set Suite Variable  ${a_id}  ${resp.json()['id']}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_P}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_P}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_P}.${test_mail}  ${views}
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Get Consumer By Id  ${CUSERNAME1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id}  ${resp.json()['userProfile']['id']}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${strt_time}=   db.subtract_timezone_time   ${tz}     3   00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  0  30 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    
    clear_Consumermsg  ${CUSERNAME1}
    clear_Providermsg  ${PUSERNAME_P}
   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence

    ${resp}=  Imageupload.providerWLCom   ${cookie}   ${wid}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  5s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cons_id}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME1}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cons_id} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-Communication Between Provider And Consumer-2
	[Documentation]  Communication Between Provider And Consumer after Done a waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    waitlistStatus=${wl_status[5]}
    clear_Consumermsg  ${CUSERNAME1}
    clear_Providermsg  ${PUSERNAME_P}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence

    ${resp}=  Imageupload.providerWLCom   ${cookie}   ${wid}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  pyproviderlogin   ${PUSERNAME_P}  ${PASSWORD}
    # Log  ${resp}
    # Should Be Equal As Strings  ${resp}  200
    # ${msg}=  Fakerlibrary.sentence
    # ${caption}=  Fakerlibrary.sentence
    # ${resp}=  Imageupload.providercomupload   ${wid}  ${msg}  ${caption}
    # Log  ${resp}
    # Should Be Equal As Strings  ${resp[1]}  200
    ${time}=  db.get_time_by_timezone   ${tz}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cons_id}  

JD-TC-Communication Between Provider And Consumer-3
	[Documentation]  Communication Between Provider And Consumer after cancel a waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[0]}   ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]} 
    clear_Consumermsg  ${CUSERNAME1}
    clear_Providermsg  ${PUSERNAME_P}  

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    Set Suite Variable   ${msg} 
    ${caption}=  Fakerlibrary.sentence

    ${resp}=  Imageupload.providerWLCom   ${cookie}   ${wid1}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
# JD-TC-Communication Between Provider And Consumer-UH1
# 	[Documentation]  Communication Between Provider And Consumer without login

#     ${msg}=   FakerLibrary.sentence
#     ${caption}=  Fakerlibrary.sentence
#     ${resp}=  Imageupload.providercomupload   ${wid}  ${msg}  ${caption}
#     Log   ${resp}
#     Should Be Equal As Strings  ${resp[1]}  419          
#     Should Be Equal As Strings  ${resp[0]}  ${SESSION_EXPIRED}

JD-TC-Communication Between Provider And Consumer-UH2
	[Documentation]  Communication Between Provider And Consumer by consumer login
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence

    ${resp}=  Imageupload.providerWLCom   ${cookie}   ${wid}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401 
    Should Be Equal As Strings  ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}
     
JD-TC-Verify Communication Between Provider And Consumer-3
	[Documentation]  Verify Communication Between Provider And Consumer after cancel a waitlist

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    sleep   3s
    ${resp}=  Get Consumer Communications
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}             ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}         ${cons_id}  



   
    
    
    
    
    
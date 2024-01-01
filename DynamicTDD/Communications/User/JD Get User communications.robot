*** Settings ***

Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        NotificationSettings
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***
${digits}       0123456789
@{EMPTY_List} 
@{person_ahead}   0  1  2  3  4  5  6
${self}         0
@{service_duration}   5   20
${parallel}     1
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2


${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf


*** Test Cases ***

JD-TC-Get User communications-1
	[Documentation]   User communicate with consumer after waitlist_Add operation

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+6900196
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E1}${\n}
    Set Suite Variable  ${MUSERNAME_E1}
    ${id}=  get_id  ${MUSERNAME_E1}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}

    ${ph1}=  Evaluate  ${MUSERNAME_E1}+1000000000
    ${ph2}=  Evaluate  ${MUSERNAME_E1}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
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
   
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  30
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    Set Suite Variable  ${BeTime30}  ${eTime}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
        ${resp}=  Enable Waitlist
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep   01s

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname}  ${resp.json()['businessName']}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+601107
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin}=  get_pincode
    Set Suite Variable  ${pin}


    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+502207
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id2}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${u_id1}   ${resp.json()[1]['id']}
    # Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}


    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
    Set Suite Variable   ${p_id}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${eTime1}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
  
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    Set Suite Variable  ${amt}
    ${totalamt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${totalamt}

    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 
    

    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${service_duration[0]}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${service_duration[0]}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid}  ${u_id1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
    
    ${resp}=  AddCustomer  ${CUSERNAME25}   firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()}

    ${resp}=  Get Consumer By Id  ${CUSERNAME25}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${uname10}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
    Set Suite Variable  ${cname1}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['userProfile']['lastName']}

    clear_Consumermsg  ${CUSERNAME25}
    clear_Providermsg  ${MUSERNAME_E1}


    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cname}  ${resp.json()['userName']}

    ${cid}=  get_id  ${CUSERNAME25}
    ${msg}=  FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${CUR_DAY}=  db.add_timezone_date  ${tz}  2   
    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${u_id1}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid0}  ${wid[0]} 
    ${resp}=  Get consumer Waitlist By Id   ${cwid0}  ${p_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Set Suite Variable  ${estTime}  ${resp.json()['serviceTime']}
   
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Consumer By Id  ${CUSERNAME25}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${cwid0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${W_uuid1}   ${resp.json()}
    
    Set Suite Variable  ${W_encId}  ${resp.json()}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.providerWLCom   ${cookie}  ${cwid0}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname}   ${resp.json()['businessName']}
    Set Test Variable  ${qTime}   ${sTime1}-${eTime1}
    ${date}=  Convert Date  ${CUR_DAY}  result_format=%d-%m-%Y

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${WaitlistNotify_msg}=  Set Variable   ${resp.json()['confirmationMessages']['Consumer_APP']}

    # ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
    # ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${bsname}
    # ${provider_msg}=   Replace String  ${provider_msg}  [message]        other
   
    ${bookingid}=  Format String  ${bookinglink}  ${W_encId}  ${W_encId}
    ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [consumer]   ${cname}
    ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [bookingId]   ${W_encId}
    # ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [providerMessage]   ${provider_msg}
 
    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${WaitlistNotify_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Consumer Login  ${CUSERNAME25}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid} 
   
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${WaitlistNotify_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}
  

JD-TC-Get User communications-2
	[Documentation]   User communicate with consumer after waitlist_Cancel operation

    
    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname1}  ${resp.json()['userName']}
    ${cid}=  get_id  ${CUSERNAME25}

    clear_Consumermsg  ${CUSERNAME25}
    clear_Providermsg  ${MUSERNAME_E1}

    ${resp}=  Cancel Waitlist  ${cwid0}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  04s

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     
    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${WaitlistNotify_msg}=  Set Variable   ${resp.json()['cancellationMessages']['Consumer_APP']} 
   
    # ${bookingid}=  Format String  ${bookinglink}  ${W_encId}  ${W_encId}
    # ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [consumer]   ${uname1}
    # ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [bookingId]   ${W_encId}

    ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
    ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${bsname}
    ${provider_msg}=   Replace String  ${provider_msg}  [message]        other
   
    ${bookingid}=  Format String  ${bookinglink}  ${W_encId}  ${W_encId}
    ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [consumer]   ${uname1}
    ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [bookingId]   ${W_encId}
    ${WaitlistNotify_msg}=  Replace String  ${WaitlistNotify_msg}  [providerMessage]   ${provider_msg}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  4s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${WaitlistNotify_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.providerWLCom   ${cookie}  ${cwid0}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
   
    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${WaitlistNotify_msg}${SPACE}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}
   
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Consumer Login  ${CUSERNAME25}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid} 

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${WaitlistNotify_msg}${SPACE}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}

JD-TC-Get User communications-3
	[Documentation]   General Communication with  user by Consumer

    ${resp}=  Consumer Login  ${CUSERNAME2}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid2}=  get_id  ${CUSERNAME2}
    
    clear_Consumermsg  ${CUSERNAME2}
    clear_Providermsg  ${MUSERNAME_E1}

    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${p_id}  ${u_id1}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}



JD-TC-Get User communications-4
    [Documentation]  General Communication with consumer by User

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cR_id5}=  get_id  ${CUSERNAME25}
    ${cR_id7}=  get_id  ${CUSERNAME27}
    clear_Consumermsg  ${CUSERNAME27}
    clear_Consumermsg  ${CUSERNAME25}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${account_id1}=  get_acc_id  ${MUSERNAME_E1}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_customer   ${MUSERNAME_E1}
    ${resp}=  AddCustomer  ${CUSERNAME27} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME25}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${u_id1}  ${cR_id7}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${u_id1}  ${cR_id5}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id7}
    Set Suite Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id5}
    Set Suite Variable  ${msgId2}  ${resp.json()[0]['messageId']}
    
    
 

JD-TC-Get User communications-5
	[Documentation]   User communicate with consumer after Appointment_Add operation

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${P_Sector}  ${decrypted_data['sector']}

    # Set Test Variable  ${P_Sector}   ${resp.json()['sector']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname}   ${resp.json()['businessName']}


    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}


    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${eTime1}

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${service_duration[0]}  ${bool1}   ${s_id1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}


    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname}  ${resp.json()['userName']}
    ${cid}=  get_id  ${CUSERNAME25} 
    clear_Consumermsg  ${CUSERNAME25}
    clear_Providermsg  ${MUSERNAME_E1}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${p_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${p}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${p}]}

    ${q}=  Random Int  max=${num_slots-2}
    Set Test Variable   ${slot2}   ${slots[${q}]}
    
    ${pcid1}=  get_id  ${CUSERNAME25}
    ${appt_for1}=  Create Dictionary  id=${self}   apptTime=${slot1}  
    ${apptfor1}=   Create List  ${appt_for1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For User    ${p_id}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${u_id1}   ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}
    # sleep  02s 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${encId}  ${encId}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id_Uname}   ${resp.json()['firstName']} ${resp.json()['lastName']}


    ${msg3}=   FakerLibrary.Word
    ${caption1}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.PAppmntComm   ${cookie}   ${apptid1}  ${msg3}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 

    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}
    # Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][1]['caption']}     ${caption1}


    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    ${converted_slot}=  convert_slot_12hr  ${slot1} 
    log    ${converted_slot}
    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    Verify Response List  ${resp}  0  waitlistId=${apptid1}  service=${SERVICE1} on ${date}  accountId=${p_id}  msg=${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid}
    # Should Not Contain   ${resp.json()[0]}   attachements
    
    ${resp}=  Consumer Login  ${CUSERNAME25}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}
    # Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][1]['caption']}     ${caption1}


    Verify Response List  ${resp}  0  waitlistId=${apptid1}  service=${SERVICE1} on ${date}  accountId=${p_id}  msg=${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid}
    # Should Not Contain   ${resp.json()[0]}   attachements

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    


JD-TC-Get User communications-6
	[Documentation]   Consumer communicate with User after Appointment_Add operation using Appointment id

    ${resp}=  Consumer Login  ${CUSERNAME25}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname1}  ${resp.json()['userName']}

    ${cid}=  get_id  ${CUSERNAME25}
    clear_Consumermsg  ${CUSERNAME25}
    clear_Providermsg  ${MUSERNAME_E1}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME25}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${msg4}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}  ${apptid1}  ${p_id}   ${msg4}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg4}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${p_id}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg4}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${p_id}




JD-TC-Get User communications-7
	[Documentation]   Communication between provider and consumer after Appointment_Cancel operation

    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname1}  ${resp.json()['userName']}
    ${cid}=  get_id  ${CUSERNAME25}

    clear_Consumermsg  ${CUSERNAME25}
    clear_Providermsg  ${MUSERNAME_E1}


    ${resp}=  Cancel Appointment By Consumer  ${apptid1}   ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s

    ${TODAY1}=  db.get_date_by_timezone  ${tz}
    ${TODAY}=  Convert Date  ${TODAY1}  result_format=%a, %d %b %Y
    ${converted_slot}=  convert_slot_12hr  ${slot1} 
    log    ${converted_slot}

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname1}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname1}
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [bookingId]   ${encId}
    
    # sleep   7s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  waitlistId=${apptid1}  service=${SERVICE1} on ${TODAY}  accountId=${p_id}  msg=${defcancel_msg}${SPACE}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid}


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME25}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${msg4}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}  ${apptid1}  ${p_id}   ${msg4}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg4}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${p_id}

    Verify Response List  ${resp}  0  waitlistId=${apptid1}  service=${SERVICE1} on ${TODAY}  accountId=${p_id}  msg=${defcancel_msg}${SPACE}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid}


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg4}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${p_id}

    Verify Response List  ${resp}  0  waitlistId=${apptid1}  service=${SERVICE1} on ${TODAY}  accountId=${p_id}  
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${u_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Get User communications-UH1
    [Documentation]  Get User communications with consumer login
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"



JD-TC-Get User communications-UH2
    [Documentation]  Get User communications using user id as zero
    ${resp}=  Consumer Login  ${CUSERNAME2}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid2}=  get_id  ${CUSERNAME2}
    
    clear_Consumermsg  ${CUSERNAME2}
    clear_Providermsg  ${MUSERNAME_E1}
    
    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${p_id}  ${u_id1}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s
    
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}

    ${resp}=  Get User communications   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_List}

    


JD-TC-Get User communications-UH3
    [Documentation]  Get User communications using Provider id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cid2}=  get_id  ${CUSERNAME2}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}

    ${resp}=  Get User communications   ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_List}



JD-TC-Get User communications-UH4
    [Documentation]  verify 'Get_User_communications' using another user id of same provider
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cid2}=  get_id  ${CUSERNAME2}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}


    ${resp}=  Get User communications   ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_List}



JD-TC-Get User communications-UH5
    [Documentation]  Get User communications using invalid Provider id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cid2}=  get_id  ${CUSERNAME2}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}

    ${INVALID_Id}=  FakerLibrary.Random Int  min=100000  max=200000
    ${resp}=  Get User communications   ${INVALID_Id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_List}


JD-TC-Get User communications-UH6
    [Documentation]  Get User communications without login
    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    

JD-TC-Get User communications-UH7
    [Documentation]  Get User communications, using disabled user_id
    ${resp}=  Consumer Login  ${CUSERNAME23}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid23}=  get_id  ${CUSERNAME23}
    
    clear_Consumermsg  ${CUSERNAME23}
    clear_Providermsg  ${MUSERNAME_E1}

    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME23}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithProvider   ${cookie}   ${p_id}  ${u_id1}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    sleep  02s

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid23}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid23}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}

    ${resp}=  EnableDisable User  ${u_id1}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s


    ${resp}=  Get User communications   ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid23}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${u_id1}




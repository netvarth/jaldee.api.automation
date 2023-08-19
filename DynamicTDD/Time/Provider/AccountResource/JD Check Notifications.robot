*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        Notification
Library           Collections
Library           String
Library           json
Library         /ebs/TDD/db.py
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}     hair_cut
${SERVICE2}     hair_cut_1
${SERVICE3}     PHONES
${SERVICE4}     PHONE
${SERVICE5}     NEWSERVICE
@{service_duration}  10  20  30   40   50
@{status}   ACTIVE   INACTIVE
${self}     0

*** Test Cases ***
JD-TC-Check Notification-1
	[Documentation]   Check Notification  after added to waitlist
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
	${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    clear_queue      ${PUSERNAME1}
    clear_location   ${PUSERNAME1}
    clear_service    ${PUSERNAME1}
    ${a_id}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable  ${a_id}
    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  AddCustomer  ${CUSERNAME5}   firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_time  5  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   6  30
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parkingType[0]}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}  
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${s_id1}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   subtract_time  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_time  3  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
   
JD-TC-Check Notification-2
	[Documentation]   Check Notification  after start a waitlist
	${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-Check Notification-3
	[Documentation]   Check Notification  after Done a waitlist
	${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id  ${s_id1}
    Verify Response  ${resp}  notification=${bool[1]}
    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Check Notification-4
	[Documentation]   Check Notification  after cancel a waitlist with cancel message
	${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname1}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cid}=  get_id  ${CUSERNAME1}
    # Set Suite Variable  ${cid}
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname}  ${resp.json()['businessName']}
    ${resp}=  AddCustomer  ${CUSERNAME1}   firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${w_encId1}=  Set Variable   ${resp.json()}

    clear_Providermsg  ${PUSERNAME1}
    clear_Consumermsg  ${CUSERNAME1}
    ${msg1}=   FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[0]}  ${msg1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}

    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname1}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}

    # ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname1}
    # ${defcancel_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    Run Keyword IF  '${len}' == '2'
        ...    Run Keywords
        # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
        ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${self}
        ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}    ${wid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${defconfirm_msg}

        ...    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${self}
        ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${jdconID1}
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    Run Keyword IF  '${len}' == '2'
        ...    Run Keywords
        # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
        ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${self}
        ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}   ${wid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${defconfirm_msg}

        ...    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${self}
        ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}   	${msg1}
        ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${jdconID1}

    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    # Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${msg1}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid1} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    Comment   Check Notification  after cancel a waitlist without cancel message

	${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cid}=  get_id  ${CUSERNAME5}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    # ${resp}=  AddCustomer  ${CUSERNAME5}   firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${w_encId1}=  Set Variable   ${resp.json()}

    clear_Providermsg  ${PUSERNAME1}
    clear_Consumermsg  ${CUSERNAME5}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[0]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s

    ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    Set Suite Variable  ${date}

    # ${msg}=  Replace String   ${cancel}  [username]  ${consumername}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
    # ${msg}=  Replace String  ${msg}  [date]  ${date}

    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}

    ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname}
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [bookingId]   ${w_encId1}

    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    Run Keyword IF  '${len}' == '2'
    ...    Run Keywords
    ...    Verify Response List  ${resp}  0  waitlistId=${wid1}  service=${SERVICE1} on ${date}  accountId=${a_id}  msg=${defconfirm_msg}
    ...    AND  Verify Response List  ${resp}  1  waitlistId=${wid1}  service=${SERVICE1} on ${date}  accountId=${a_id}  msg=${defcancel_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${self}
    # ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['userName']}  ${bname} 
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${jdconID}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}  ${consumername}
    ...    ELSE IF  '${len}' == '1'
    ...    Run Keywords
    ...    Verify Response List  ${resp}  0  waitlistId=${wid1}  service=${SERVICE1} on ${date}  accountId=${a_id}  msg=${defcancel_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${self}
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${jdconID}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}

	${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  1  waitlistId=${wid1}  service=${SERVICE1} on ${date}  accountId=${a_id}  msg=${defcancel_msg}
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${self}
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${jdconID}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${consumername}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Check Notification-5
	[Documentation]   Check Notification  after add a delay
	${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${w_encId1}=  Set Variable   ${resp.json()}
    sleep  03s
    clear_Providermsg  ${PUSERNAME1}
    clear_Consumermsg  ${CUSERNAME5}
    ${delay_time}=   Random Int  min=10   max=40
    ${resp}=  Add Delay  ${qid1}  ${delay_time}  ${None}  true
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defapptDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}

    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${delay_time}=   Convert To String  ${delay_time}
    # ${msg}=  Replace String    ${delay}  [username]  ${consumername}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
    # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
    # ${msg}=  Replace String  ${msg}  [time]  ${delay_time}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname1}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}

    ${hrs}  ${mins}=   Convert_hour_mins   ${delay_time}
    ${msg}=  Replace String  ${defapptDelayAdd_msg}  [consumer]   ${uname1}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${w_encId1}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    Log  ${msg}
    sleep  10s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  waitlistId=${wid1}  service=${SERVICE1} on ${date}  accountId=${a_id}  msg=${msg} 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername}

	${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${self}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   	 	${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid}


JD-TC-Check Notification-6
    [Documentation]  check alerts when waitlist cancled by consumer
    ${resp}=  ProviderLogin  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    clear_queue      ${PUSERNAME5}
    clear_location   ${PUSERNAME5}
    clear_service    ${PUSERNAME5}
    clear_customer   ${PUSERNAME5}
    ${a_id}=  get_acc_id  ${PUSERNAME5}
    Set Suite Variable  ${a_id}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}
    # ${resp}=  AddCustomer  ${CUSERNAME5}   firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid2}  ${resp.json()}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet']
    Set Suite Variable  ${parking_type}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_time  5  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   6  30
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}  
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${s_id1}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${strt_time}=   subtract_time  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_time  3  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}  ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}
    # ${cid}=  get_id  ${CUSERNAME5}
    ${DAY3}=  add_date  5
    ${resp}=  Add To Waitlist Consumers  ${a_id}  ${q1_l1}  ${DAY3}  ${sId_1}  ${desc}  ${bool[0]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]} 

    # ${resp}=   Get Waitlist EncodedId    ${wid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${w_encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${a_id}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
    Set Suite Variable  ${w_encId1}   ${resp.json()['checkinEncId']}

    clear_Providermsg  ${PUSERNAME5}
    clear_Consumermsg  ${CUSERNAME5}
    ${resp}=  Cancel Waitlist  ${wid1}   ${a_id}  
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  06s
    # ${msg}=  Replace String    ${consumerCancel}  [username]  ${consumername}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
    # ${msg}=  Replace String  ${msg}  [date]  ${date}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}

    ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname}
    ${defcancel_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}

    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${self}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${defcancel_msg}  
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${jdconID} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderLogin  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${self}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    	${defcancel_msg}  
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${jdconID}
 

JD-TC-Check Notification-7
    [Documentation]  check alerts when agent cancel waitlist
    ${resp}=  ProviderLogin  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    clear_queue      ${PUSERNAME7}
    clear_location   ${PUSERNAME7}
    clear_service    ${PUSERNAME7}
    ${a_id}=  get_acc_id  ${PUSERNAME7}
    Set Suite Variable  ${a_id}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}
    # ${resp}=  AddCustomer  ${CUSERNAME5}   firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid3}  ${resp.json()}
    ${city}=   get_place
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet']
    Set Suite Variable  ${parking_type}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_time  5  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   6  30
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}  
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
    ${Total}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${strt_time}=   subtract_time  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_time  3  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}  ${resp.json()}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bname}  ${resp.json()['businessName']}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Set Suite Variable  ${consumername}  ${resp.json()['userName']} 
    ${cid}=  get_id  ${CUSERNAME5}    
    clear_Providermsg  ${PUSERNAME7}
    clear_Consumermsg  ${CUSERNAME5}
    ${resp}=  Add To Waitlist Consumers  ${a_id}  ${q1_l1}  ${DAY1}  ${sId_1}  ${desc}  ${bool[0]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    # ${resp}=   Get Waitlist EncodedId    ${wid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${w_encId1}=  Set Variable   ${resp.json()}
    sleep  03s    
    ${cid3}   get_procon_id   ${PUSERNAME7}   ${CUSERNAME5}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${a_id}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[3]}  partySize=1  waitlistedBy=CONSUMER  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${sId_1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['id']}  ${cid3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid3}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q1_l1}
    Set Test Variable  ${w_encId1}   ${resp.json()['checkinEncId']}
    clear_Providermsg  ${PUSERNAME7}
    clear_Consumermsg  ${CUSERNAME5}
    change_system_time  0  30
    # sleep  90s
    # sleep  20s
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${a_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[3]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER
    sleep  5s
    # ${msg}=  Replace String    ${cancel}  [username]  ${consumername}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
    # ${msg}=  Replace String  ${msg}  [date]  ${date}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}

    ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname}
    ${defcancel_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${w_encId1}
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y

    # Verify Response List  ${resp}  0  waitlistId=${wid1}  service=${SERVICE1} on ${date}  accountId=${a_id}  msg=${defcancel_msg}  
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    # # Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid3}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername}

*** Comment ***
JD-TC-Check Notification-8
    [Documentation]  check alerts when bill created
    ${resp}=  ProviderLogin  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Update Tax Percentage  18  13DEFBV1100M2Z6
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200  
    ${pid}=  get_acc_id  ${PUSERNAME7} 
    ${cid}=  get_id  ${CUSERNAME2}
    Set Suite Variable  ${cid}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${q1_l1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    sleep  02s
    clear_Providermsg  ${PUSERNAME1}
    clear_Consumermsg  ${CUSERNAME2}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    sleep  2s
    ${resp}=  Accept Payment  ${wid}  self_pay  500  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


*** Comment ***
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id}=  get_id  ${PUSERNAME7}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   	joshi nv, An Invoice for the amount of Rs.590.0 has been generated for services rendered from Devi Health Care and is ready for payment.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid} 
    
    
        
*** Comment ***
JD-TC-Check Notification-6
	[Documentation]   Check Notification send to next and next to next person after start a waitlist
	${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${a_id}=  get_acc_id  ${PUSERNAME2}
    Set Suite Variable  ${a_id}
    ${resp}=  Update Waitlist Settings  ML  30  true  true  true  true  ${EMPTY}  False
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  Thiruth  ${longi}  ${latti}  www.sampleurl.com  680220  Palliyil House  free  True  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE1}  Description   30  ACTIVE  Waitlist  True  email  45  500  True  False
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id11}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  Description   30  ACTIVE  Waitlist  True  email  45  500  True  False
    Should Be Equal As Strings  ${resp.status_code}  200      
    Set Suite Variable  ${s_id2}  ${resp.json()}
    
    Set Suite Variable  ${list}  ${list}
    ${resp}=  Create Queue  ${queue2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  8  ${lid}  ${s_id11}  ${s_id2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}
    ${cid1}=  get_id  ${CUSERNAME5}
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id11}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${cid2}=  get_id  ${CUSERNAME1}
    ${resp}=  Add To Waitlist  ${cid2}  ${s_id2}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${cid3}=  get_id  ${CUSERNAME2}
    ${resp}=  Add To Waitlist  ${cid3}  ${s_id11}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${cid4}=  get_id  ${CUSERNAME3}
    ${resp}=  Add To Waitlist  ${cid4}  ${s_id2}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid[0]}
    sleep  02s
    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME5}
    clear_Consumermsg  ${CUSERNAME1}
    clear_Consumermsg  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME3}

    ${resp}=  Waitlist Action  STARTED  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${time}=  db.get_time
    sleep  02s
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${self}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  subair nv, Your service with Devi Health Care for hair_cut services, started at ${time}.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid1}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid2}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   subair nv, You are NEXT IN LINE with Devi Health Care for hair_cut_1.Your expected waiting time now is 0  mins. Please be ready to avoid any delay as we will keep updating you.
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${cid2}
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}  ${wid3}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}   joshi nv, You are ONE AWAY TO NEXT with Devi Health Care for hair_cut service. Your expected waiting time now is 30 mins. Please arrive at the premises to avoid any delay.
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}  ${cid3}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  subair nv, You are NEXT IN LINE with Devi Health Care for hair_cut_1.Your expected waiting time now is 0  mins. Please be ready to avoid any delay as we will keep updating you.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid2} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  joshi nv, You are ONE AWAY TO NEXT with Devi Health Care for hair_cut service. Your expected waiting time now is 30 mins. Please arrive at the premises to avoid any delay.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid3} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME5}
    clear_Consumermsg  ${CUSERNAME1}
    clear_Consumermsg  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME3}

    ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    change_system_time  0  5
    ${resp}=  Waitlist Action  STARTED  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${time}=  db.get_time
    sleep  02s
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    subair nv, Your service with Devi Health Care for hair_cut_1 services, started at ${time}. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid2}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid3}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}  joshi nv, You are NEXT IN LINE with Devi Health Care for hair_cut.Your expected waiting time now is 0  mins. Please be ready to avoid any delay as we will keep updating you. 
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${cid3}
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}  ${wid4}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}  joshi nv, You are ONE AWAY TO NEXT with Devi Health Care for hair_cut_1 service. Your expected waiting time now is 5  mins. Please arrive at the premises to avoid any delay. 
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}  ${cid4}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  joshi nv, You are NEXT IN LINE with Devi Health Care for hair_cut.Your expected waiting time now is 0  mins. Please be ready to avoid any delay as we will keep updating you. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid3} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  joshi nv, You are ONE AWAY TO NEXT with Devi Health Care for hair_cut_1 service. Your expected waiting time now is 5  mins. Please arrive at the premises to avoid any delay. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid4} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
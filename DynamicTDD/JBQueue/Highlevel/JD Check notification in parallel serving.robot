*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Communications
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***

JD-TC-Check Notification-1
	[Documentation]   Check Notification send to consumer when cancel a waitlist and parallel serving as 3
	
    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Set Test Variable  ${uname}  ${resp.json()['userName']}
    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Set Test Variable  ${uname1}  ${resp.json()['userName']}
    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${PO_Number1}    Generate random string    5    0123456789
    ${PO_Number1}    Convert To Integer  ${PO_Number1}
    ${PO_Number2}    Generate random string    5    0123456789
    ${PO_Number2}    Convert To Integer  ${PO_Number2}

    ${CUSERPH1}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    Set Suite Variable  ${CUSERPH1}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${uname}  ${resp.json()['userName']}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUSERPH2}=  Evaluate  ${CUSERNAME}+${PO_Number2}
    Set Suite Variable  ${CUSERPH2}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${uname1}  ${resp.json()['userName']}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pR_id20}  ${decrypted_data['id']}
    Set Suite Variable  ${pname20}  ${decrypted_data['userName']}
    # Set Suite Variable  ${pR_id20}  ${resp.json()['id']}
    # Set Suite Variable  ${pname20}  ${resp.json()['userName']}
    
    # sleep  1s
    # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
        Should Be Equal As Strings  ${resp1.status_code}  200
    # ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    END

    clear_location   ${PUSERNAME141}
    clear_customer   ${PUSERNAME141}
    clear_Providermsg  ${PUSERNAME141}
    clear_Consumermsg  ${CUSERPH2}
    clear_Consumermsg  ${CUSERPH1}
    ${con_id}=  get_id  ${CUSERPH1}
    ${con_id1}=  get_id   ${CUSERPH2}

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${lid}=  Create Sample Location 
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${Time}=  db.get_time_by_timezone   ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  45  
    ${eTime}=  add_timezone_time  ${tz}  1  00  
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  3  8  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}   ${resp.json()}

    ${resp}=  Get Consumer By Id  ${CUSERPH1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${uname_c20}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
    Set Suite Variable  ${cname1}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['userProfile']['lastName']}


    ${resp}=  AddCustomer  ${CUSERPH1}  firstName=${cname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${consumernote}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${consumernote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    
    ${resp}=  Get Consumer By Id  ${CUSERPH2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${uname_c22}   ${resp.json()['userProfile']['firstName']} ${resp.json()['userProfile']['lastName']}
    Set Suite Variable  ${cname2}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['userProfile']['lastName']}


    ${resp}=  AddCustomer  ${CUSERPH2}   firstName=${cname2}   lastName=${lname2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${qid}  ${DAY}  ${consumernote}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bname}  ${resp.json()['businessName']}
    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SERVICE}  ${resp.json()['name']}

    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}  ${None}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${W_uuid1}   ${resp.json()}
    
    Set Suite Variable  ${W_encId1}  ${resp.json()}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push0}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg0}=  Set Variable   ${resp.json()['cancellationMessages']['Consumer_APP']}
    
    ${bookingid1}=  Format String  ${bookinglink}  ${W_encId1}  ${W_encId1}
    ${defconfirm_msg0}=  Replace String  ${confirmAppt_push0}  [consumer]   ${uname}
    ${defconfirm_msg0}=  Replace String  ${defconfirm_msg0}  [bookingId]   ${W_encId1}

    ${defaultmsg0}=  Replace String  ${defconsumerCancel_msg0}  [consumer]   ${uname}
    ${defconsumerCancel_msg0}=  Replace String  ${defaultmsg0}  [bookingId]   ${W_encId1}
    ${defconsumerCancel_msg0}=  Replace String  ${defconsumerCancel_msg0}  [providerMessage]   ${EMPTY}

    ${resp}=   Get Waitlist EncodedId    ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${W_uuid2}   ${resp.json()}
    
    Set Suite Variable  ${W_encId2}  ${resp.json()}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push1}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg1}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}
    
    ${bookingid2}=  Format String  ${bookinglink}  ${W_encId2}  ${W_encId2}
    ${defconfirm_msg1}=  Replace String  ${confirmAppt_push1}  [consumer]   ${uname_c22}
    ${defconfirm_msg1}=  Replace String  ${defconfirm_msg1}  [bookingId]   ${W_encId2}

    ${defaultmsg1}=  Replace String  ${defconsumerCancel_msg1}  [consumer]   ${uname_c22}
    ${defconsumerCancel_msg1}=  Replace String  ${defaultmsg1}  [bookingId]   ${W_encId2}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${a_id}=  get_acc_id  ${PUSERNAME141}

    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Cancel Waitlist  ${wid2}  ${a_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    Sleep  2s
    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${c_id1}  ${resp.json()['id']}
    # Set Test Variable  ${uname}  ${resp.json()['userName']}
    ${DATE}=  Convert Date  ${DAY}  result_format=%d-%m-%Y
    ${DATE1}=  Convert Date  ${DAY}  result_format=%a, %d %b %Y
    # ${msg}=  Replace String    ${chekIncanceled}  [username]  ${uname1}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE}
    # ${msg}=  Replace String  ${msg}  [date]  ${DAY}
    sleep   4s
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200 
    Log  ${resp.json()}
    Verify Response List  ${resp}  0  waitlistId=${wid1}  service=${SERVICE} on ${DATE1}  accountId=${a_id}  msg=${defconfirm_msg0} 
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    0
    # Should Be Equal As Strings  ${resp.json()[1]['owner']['name']}  ${pname20} 
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${con_id}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}  ${uname}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[1]['accountName']}  ${bname}


    Verify Response List  ${resp}  1  waitlistId=${wid1}  service=${SERVICE} on ${DATE1}  accountId=${a_id}  msg=${defconsumerCancel_msg0} 
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    0
    # Should Be Equal As Strings  ${resp.json()[1]['owner']['name']}  ${pname20} 
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${con_id}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}  ${uname}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[1]['accountName']}  ${bname}


    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    # Set Test Variable  ${uname7}  ${resp.json()['userName']}
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${msg}=  Replace String    ${consumerCancel}  [username]  ${uname7}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE}
    # ${msg}=  Replace String  ${msg}  [date]  ${DAY}
    Verify Response List  ${resp}  0  waitlistId=${wid2}  service=${SERVICE} on ${DATE1}  accountId=${a_id}  msg=${defconfirm_msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${pname20} 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${con_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${uname1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountName']}  ${bname}

    Verify Response List  ${resp}  1  waitlistId=${wid2}  service=${SERVICE} on ${DATE1}  accountId=${a_id}  msg=${defconsumerCancel_msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${pname20} 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${con_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${uname1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountName']}  ${bname}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    
*** Comment ***
JD-TC-Check Notification-1
	Comment   Check Notification send to next and next to next person after start a waitlist and parallel serving as 3
	${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${a_id}=  get_acc_id  ${PUSERNAME2}
    Set Test Variable  ${a_id}
    ${resp}=  Update Waitlist Settings  ML  30  true  true  true  true  ${EMPTY}  False
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  Thiruth  ${longi}  ${latti}  www.sampleurl.com  680220  Palliyil House  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE1}  Description   30  ACTIVE  Waitlist  True  email  45  500  True  False
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id11}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  Description   30  ACTIVE  Waitlist  True  email  45  500  True  False
    Should Be Equal As Strings  ${resp.status_code}  200      
    Set Test Variable  ${s_id2}  ${resp.json()}
    
    Set Test Variable  ${list}  ${list}
    ${resp}=  Create Queue  ${queue2}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  3  8  ${lid}  ${s_id11}  ${s_id2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${qid2}  ${resp.json()}

    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME}
    clear_Consumermsg  ${CUSERPH1}
    clear_Consumermsg  ${CUSERPH2}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME4}
    ${cid1}=  get_id  ${CUSERNAME}
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id11}  ${qid2}  ${DAY1}  hi  True  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${cid2}=  get_id  ${CUSERPH1}
    ${resp}=  Add To Waitlist  ${cid2}  ${s_id2}  ${qid2}  ${DAY1}  hi  True  ${cid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${cid3}=  get_id  ${CUSERPH2}
    ${resp}=  Add To Waitlist  ${cid3}  ${s_id11}  ${qid2}  ${DAY1}  hi  True  ${cid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    ${cid4}=  get_id  ${CUSERNAME3}
    ${resp}=  Add To Waitlist  ${cid4}  ${s_id2}  ${qid2}  ${DAY1}  hi  True  ${cid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}
    ${cid5}=  get_id  ${CUSERNAME4}
    ${resp}=  Add To Waitlist  ${cid5}  ${s_id2}  ${qid2}  ${DAY1}  hi  True  ${cid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    sleep  02s

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200   
    ${resp}=  ConsumerLogin  ${CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   subair nv, Your online check-in with Devi Health Care for hair_cut service has been successful. Your estimated waiting time is 0 mts. We will keep you notified of queue status changes.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid1} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    subair nv, Your online check-in with Devi Health Care for hair_cut_1 service has been successful. Your estimated waiting time is 0 mts. We will keep you notified of queue status changes. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid2} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   joshi nv, Your online check-in with Devi Health Care for hair_cut service has been successful. Your estimated waiting time is 0 mts. We will keep you notified of queue status changes.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid3} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    	joshi nv, Your online check-in with Devi Health Care for hair_cut_1 service has been successful. Your estimated waiting time is 10 mts. We will keep you notified of queue status changes. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid4} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    	joshi nv, Your online check-in with Devi Health Care for hair_cut_1 service has been successful. Your estimated waiting time is 20 mts. We will keep you notified of queue status changes. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid5} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

	${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME}
    clear_Consumermsg  ${CUSERPH1}
    clear_Consumermsg  ${CUSERPH2}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME4}
    ${resp}=  Waitlist Action  STARTED  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${Time}=  db.get_time_by_timezone   ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    sleep  03s
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200   
    ${resp}=  ConsumerLogin  ${CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  subair nv, Your service with Devi Health Care for hair_cut services, started at ${time}.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid1}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  joshi nv, You are NEXT IN LINE with Devi Health Care for hair_cut_1.Your expected waiting time now is 0 mts. Please be ready to avoid any delay as we will keep updating you.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid4} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  joshi nv, You are ONE AWAY TO NEXT with Devi Health Care for hair_cut_1 service. Your expected waiting time now is 10 mts. Please arrive at the premises to avoid any delay. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid5} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME}
    clear_Consumermsg  ${CUSERPH1}
    clear_Consumermsg  ${CUSERPH2}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME4}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    change_system_time  0  5
    ${resp}=  Waitlist Action  STARTED  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${Time}=  db.get_time_by_timezone   ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    sleep  02s
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${resp}=  ConsumerLogin  ${CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  subair nv, Your service with Devi Health Care for hair_cut_1 services, started at ${time}.  
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid2}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  joshi nv, You are NEXT IN LINE with Devi Health Care for hair_cut_1.Your expected waiting time now is 0 mts. Please be ready to avoid any delay as we will keep updating you.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid5} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME}
    clear_Consumermsg  ${CUSERPH1}
    clear_Consumermsg  ${CUSERPH2}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME4}
    clear_Consumermsg  ${GIN_CUSERNAME}
    clear_Consumermsg  ${CUSERNAME5}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid6}=  get_id  ${GIN_CUSERNAME}
    ${resp}=  Add To Waitlist  ${cid6}  ${s_id11}  ${qid2}  ${DAY1}  hi  True  ${cid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    sleep  02s
    ${cid7}=  get_id  ${CUSERNAME5}
    ${resp}=  Add To Waitlist  ${cid7}  ${s_id11}  ${qid2}  ${DAY1}  hi  True  ${cid7}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid7}  ${wid[0]}
    sleep  02s
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 
     
    ${resp}=  ConsumerLogin  ${GIN_CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   subair nv, Your online check-in with Devi Health Care for hair_cut service has been successful. Your estimated waiting time is 5 mts. We will keep you notified of queue status changes.
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid6} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}     	melvin nv, Your online check-in with Devi Health Care for hair_cut service has been successful. Your estimated waiting time is 10 mts. We will keep you notified of queue status changes. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cid7} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME}
    clear_Consumermsg  ${CUSERPH1}
    clear_Consumermsg  ${CUSERPH2}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME4}
    clear_Consumermsg  ${GIN_CUSERNAME}
    clear_Consumermsg  ${CUSERNAME5}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    change_system_time  0  5
    ${resp}=  Waitlist Action  STARTED  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${Time}=  db.get_time_by_timezone   ${tz}
    ${Time}=  db.get_time_by_timezone  ${tz}
    sleep  02s
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  ConsumerLogin  ${CUSERPH2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid3}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  joshi nv, Your service with Devi Health Care for hair_cut services, started at ${time}. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid3}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${GIN_CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   	subair nv, You are NEXT IN LINE with Devi Health Care for hair_cut.Your expected waiting time now is 0 mts. Please be ready to avoid any delay as we will keep updating you. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid6} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  melvin nv, You are ONE AWAY TO NEXT with Devi Health Care for hair_cut service. Your expected waiting time now is 5 mts. Please arrive at the premises to avoid any delay. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid7} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Providermsg  ${PUSERNAME2}
    clear_Consumermsg  ${CUSERNAME}
    clear_Consumermsg  ${CUSERPH1}
    clear_Consumermsg  ${CUSERPH2}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME4}
    clear_Consumermsg  ${GIN_CUSERNAME}
    clear_Consumermsg  ${CUSERNAME5} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action Cancel  ${wid4}  noshowup  ${None}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${resp}=  Get Waitlist By Id  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=cancelled
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid4}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   	 	joshi nv, Your waitlist with Devi Health Care for hair_cut_1 service has been cancelled due to noshowup. Sorry for the inconvenience caused. For refund or payment adjustments, please contact Devi Health Care. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid4}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${GIN_CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  [] 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   ${a_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  melvin nv, Your wait time has been moved to an earlier. Your expected waiting time will now be 0 mts. We will keep you posted when it's your turn. 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid7} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

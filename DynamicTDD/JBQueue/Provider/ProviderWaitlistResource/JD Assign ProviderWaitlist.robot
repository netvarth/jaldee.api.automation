*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Vacation
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${digits}       0123456789
${P_PASSWORD}        Netvarth008
${C_PASSWORD}        Netvarth009
${waitlistedby}           PROVIDER
@{countryCode}   91  +91  48 
@{service_names}

***Test Cases***

JD-TC-AssignproviderWaitlist-1
    [Documentation]  Assingn waitlist to user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # clear_queue      ${HLPUSERNAME2}
    # clear_service    ${HLPUSERNAME2}
    # clear_customer   ${HLPUSERNAME2}

    ${pid}=  get_acc_id  ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    # ${ph1}=  Evaluate  ${HLPUSERNAME4}+1000440000
    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${dob}=  FakerLibrary.Date

    # FOR    ${i}    IN RANGE    3
    #     ${pin}=  get_pincode
    #     ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    #     IF    '${kwstatus}' == 'FAIL'
    #             Continue For Loop
    #     ELSE IF    '${kwstatus}' == 'PASS'
    #             Exit For Loop
    #     END
    # END
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200 

    ${ph1}  ${u_id1} =  Create and Configure Sample User
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE1}  ${description}  ${dur}  ${bool[0]}  ${amt}  ${bool[0]}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${ph2}  ${u_id2} =  Create and Configure Sample User
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${u_id2}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE2}   ${description}  ${dur}  ${bool[0]}  ${amt}  ${bool[0]}  provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${ph3}  ${u_id3} =  Create and Configure Sample User
    Set Suite Variable  ${ph3}
    Set Suite Variable  ${u_id3}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  15  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service  ${SERVICE3}  ${description}  ${dur}  ${bool[0]}  ${amt}  ${bool[0]}  provider=${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id3}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id3}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id3}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          ${u_id1}

JD-TC-AssignproviderWaitlist-2
    [Documentation]  Assingn waitlist to user and then it again assign to another user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}  ${ser_duratn}  ${bool[0]}  ${servicecharge}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}
    

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1}=  Create Sample User 
    Set suite Variable                    ${u_id1}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${SERVICE2}=    generate_service_name 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${dur}    ${bool[0]}   ${amt}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    # sleep  02s

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${u_id2}=  Create Sample User 
    Set suite Variable                    ${u_id2}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${SERVICE3}=    generate_service_name 
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${dur}    ${bool[0]}     ${amt}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}   ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


JD-TC-AssignproviderWaitlist-3
    [Documentation]  Assingn waitlist to user here user doesn't have any service and queue
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}    ${bool[0]}    ${servicecharge}  ${bool[0]}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1}=  Create Sample User 
    Set suite Variable                    ${u_id1}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


JD-TC-AssignproviderWaitlist-4
    [Documentation]  Assingn waitlist to user and it reAssingn to the same user 
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}    ${bool[0]}   ${servicecharge}  ${bool[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${u_id1}=  Create Sample User 
    Set suite Variable                    ${u_id1}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${SERVICE2}=    generate_service_name 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE2}  ${description}   ${dur}    ${bool[0]}     ${amt}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue   ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${u_id2}=  Create Sample User 
    Set suite Variable                    ${u_id2}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15 
    ${SERVICE3}=    generate_service_name 
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE3}  ${description}   ${dur}   ${bool[0]}     ${amt}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue   ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}   ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


JD-TC-AssignproviderWaitlist-5
    [Documentation]  Assingn waitlist to user and user generate bill
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[0]}    ${servicecharge}  ${bool[0]}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${ser_id}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${PUSERNAME_U1}  ${u_id1} =  Create and Configure Sample User

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2} 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${dur}    ${bool[0]}    ${amt}  ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id1}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue   ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}    ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${PUSERNAME_U2}  ${u_id2} =  Create and Configure Sample User

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Booking Invoices  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Set Suite Variable  ${invoice_uid}   ${resp.json()[0]['invoiceUid']}

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${resp}=    Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${resp}=  Get Payment Details By UUId   ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AssignproviderWaitlist-6
    [Documentation]  Assingn 3 waitlist to the same user and get count
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${ph1}  ${u_id1} =  Create and Configure Sample User
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2} 
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${dur}  ${bool[0]}   ${amt}  ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue   ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}    ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${u_id2}=  Create Sample User 
    Set suite Variable                    ${u_id2}

    ${SERVICE3}=    generate_service_name 
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE3}  ${description}   ${dur}   ${bool[0]}    ${amt}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue   ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}    ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign provider Waitlist   ${wid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign provider Waitlist   ${wid2}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Count Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid}
    Verify Response List  ${resp}  1  ynwUuid=${wid1}
    Verify Response List  ${resp}  2  ynwUuid=${wid2}

JD-TC-AssignproviderWaitlist-7
    [Documentation]  Assingn waitlist to user here user contain user side waitlist and assigned waitlist 
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sud_domain_id3}  ${resp2.json()['serviceSubSector']['id']}

    clear_customer   ${HLPUSERNAME11}

    ${pid}=  get_acc_id  ${HLPUSERNAME11}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Enable Disable Department  ${toggle[1]}   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid3}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    # sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME11}+1000440000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date

    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${whpnum}=  Evaluate  ${HLPUSERNAME11}+336945
    ${tlgnum}=  Evaluate  ${HLPUSERNAME11}+336845

    ${ph1}  ${u_id1} =  Create and Configure Sample User        deptId=${dep_id3}
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2} 
    ${resp}=  Create Service   ${SERVICE2}  ${description}   ${dur}   ${bool[0]}   ${amt}  ${bool[0]}   department=${dep_id3}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id3}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime3}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid3}  ${u_id1}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id3}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${cid3}  ${s_id3}  ${que_id3}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${u_wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${u_wid}  ${u_wid[0]}

    ${resp}=  Get Waitlist By Id  ${u_wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${u_wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AssignproviderWaitlist-8
    [Documentation]  Assingn waitlist to a assistant user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sud_domain_id3}  ${resp2.json()['serviceSubSector']['id']}

    clear_customer   ${HLPUSERNAME11}

    ${pid}=  get_acc_id  ${HLPUSERNAME11}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Enable Disable Department  ${toggle[1]} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid3}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    # sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME11}+1000450000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date

    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${ph1}  ${u_id1} =  Create and Configure Sample User    deptId=${dep_id3}
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


JD-TC-AssignproviderWaitlist-9
    [Documentation]  Try to Assingn a done state waitlist
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sud_domain_id3}  ${resp2.json()['serviceSubSector']['id']}

    clear_customer   ${HLPUSERNAME11}

    ${pid}=  get_acc_id  ${HLPUSERNAME11}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Enable Disable Department  ${toggle[1]} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${strt_time}=   db.get_time_by_timezone  ${tz}     
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid3}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[4]}    ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    # sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME11}+1000470000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date

    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${whpnum}=  Evaluate  ${HLPUSERNAME11}+336245
    ${tlgnum}=  Evaluate  ${HLPUSERNAME11}+336345

    ${ph1}  ${u_id1} =  Create and Configure Sample User    deptId=${dep_id3}
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}
    

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2} 
    ${resp}=  Create Service   ${SERVICE2}  ${description}   ${dur}    ${bool[0]}   ${amt}  ${bool[0]}   department=${dep_id3}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id3}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime3}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid3}  ${u_id1}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id3}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderWaitlist-10
    [Documentation]  Assingn waitlist to a admin user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sud_domain_id3}  ${resp2.json()['serviceSubSector']['id']}

    clear_customer   ${HLPUSERNAME11}

    ${pid}=  get_acc_id  ${HLPUSERNAME11}


    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Enable Disable Department  ${toggle[1]} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid3}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    # sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME11}+1000650000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date

    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${ph1}  ${u_id1} =  Create and Configure Sample User    deptId=${dep_id3}
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

JD-TC-AssignproviderWaitlist-UH1
    [Documentation]  User take checkin and try to assign another user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ph1}  ${u_id1} =  Create and Configure Sample User
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2} 
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${dur}    ${bool[0]}    ${amt}  ${bool[0]}    provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${ph2}  ${u_id2} =  Create and Configure Sample User
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${u_id2}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3} 
    ${resp}=  Create Service   ${SERVICE3}  ${description}   ${dur}    ${bool[0]}   ${amt}  ${bool[0]}  provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${CANNOT_ASSIGN_PROVIDER}"

JD-TC-AssignproviderWaitlist-UH3
    [Documentation]  Assingn waitlist to a invalid user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    # clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[0]}   ${servicecharge}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${ph2}  ${u_id2} =  Create and Configure Sample User
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${u_id2}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3} 
    ${resp}=  Create Service   ${SERVICE3}  ${description}   ${dur}  ${bool[0]}    ${amt}  ${bool[0]}    provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   000
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${USER_NOT_FOUND}"
    

JD-TC-AssignproviderWaitlist-UH4
    [Documentation]  Assingn waitlist to user by using invalid waitlist id
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}    ${bool[0]}    ${servicecharge}  ${bool[0]}  
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ph2}  ${u_id2} =  Create and Configure Sample User
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${u_id2}

    ${SERVICE3}=    generate_service_name 
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${dur}    ${bool[0]}    ${amt}  ${bool[0]}  provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   000   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.content}  "${INVALID_WTLST_ID}"

JD-TC-AssignproviderWaitlist-UH5 
    [Documentation]  Assingn waitlist to another account's user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sud_domain_id1}  ${resp2.json()['serviceSubSector']['id']}

    clear_customer   ${HLPUSERNAME10}

    ${pid}=  get_acc_id  ${HLPUSERNAME10}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Enable Disable Department  ${toggle[1]} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=   generate_firstname
    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid1}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

    ${ph1}  ${u_id5} =  Create and Configure Sample User   deptId=${dep_id1}
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id5}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE1}  ${description}   ${dur}    ${bool[0]}     ${amt}  ${bool[0]}    department=${dep_id1}  provider=${u_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${u_id5}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}    ${bool[0]}   ${servicecharge}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ph2}  ${u_id2} =  Create and Configure Sample User  
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${u_id2}
    
    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3} 
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE3}  ${description}   ${dur}    ${bool[0]}     ${amt}  ${bool[0]}   provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${NO_PERMISSION}"

JD-TC-AssignproviderWaitlist-UH6
    [Documentation]  Try to Assingn a canceled waitlist
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[0]}    ${servicecharge}  ${bool[0]}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    ${resp}=  Waitlist Action    ${waitlist_actions[2]}  ${wid}  cancelReason=${cncl_resn}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ph2}  ${u_id2} =  Create and Configure Sample User
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${u_id2}
    
    ${SERVICE3}=    generate_service_name 
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE3}  ${description}   ${dur}    ${bool[0]}    ${amt}  ${bool[0]}     provider=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${CANNOT_ASSIGN_WL}=   Replace String  ${CANNOT_ASSIGN_WL}  {}  ${wl_status[4]}

    ${resp}=   Assign provider Waitlist    ${wid}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${CANNOT_ASSIGN_WL}"


JD-TC-AssignproviderWaitlist-UH7
    [Documentation]  Try to Assingn waitlist through consumer login
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${HLPUSERNAME2}
    ${account_id}=  get_acc_id  ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[0]}   ${servicecharge}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid6} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ph2}  ${u_id6} =  Create and Configure Sample User
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${u_id6}
    
    ${SERVICE3}=    generate_service_name 
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE3}  ${description}   ${dur}   ${bool[0]}    ${amt}  ${bool[0]}  provider=${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id6}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    
    ${resp}=  Send Otp For Login    ${CUSERNAME8}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=  Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}    JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Assign provider Waitlist    ${wid6}   ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-AssignproviderWaitlist-UH8
    [Documentation]   Assingn waitlist without login
    
    ${resp}=   Assign provider Waitlist    ${wid6}   ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"

JD-TC-AssignproviderWaitlist-UH9
    [Documentation]  Try to Assingn a started waitlist
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sud_domain_id3}  ${resp2.json()['serviceSubSector']['id']}

    clear_customer   ${HLPUSERNAME11}

    ${pid}=  get_acc_id  ${HLPUSERNAME11}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Enable Disable Department  ${toggle[1]} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid3}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  
    
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
 
    ${strt_time}=   db.get_time_by_timezone  ${tz}     
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid3}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}    ${wid}     
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    # sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()['departments'][0]['departmentId']}

    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${ph1}  ${u_id1} =  Create and Configure Sample User  deptId=${dep_id3}
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime3}

    ${SERVICE2}=    generate_service_name 
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service   ${SERVICE2}  ${description}   ${dur}    ${bool[0]}   ${amt}  ${bool[0]}    department=${dep_id3}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id3}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid3}  ${u_id1}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id3}  ${resp.json()}

    ${CANNOT_ASSIGN_WL}=   Replace String  ${CANNOT_ASSIGN_WL}  {}  ${wl_status[2]}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${CANNOT_ASSIGN_WL}"




























*** Comments ***


JD-TC-CreateUser -0
    [Documentation]  Create 20 users by branch login and assign waitlist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # clear_queue      ${PUSERNAME58}
    # clear_service    ${PUSERNAME58}
    clear_customer   ${PUSERNAME58}

    ${pid}=  get_acc_id  ${PUSERNAME58}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}
    ${resp}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${resp}=   Create Sample Service  ${SERVICE3}
    Set Suite Variable    ${ser_id3}    ${resp}    

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=20   max=30
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${waitlist_ids}=  Create List

    FOR   ${a}  IN RANGE   20
            
        ${cons_num}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${resp}=  AddCustomer  ${CUSERPH${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${ser_id}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${waitlist_ids}  ${wid${a}}

    END
      
    Log   ${waitlist_ids}
    Log   ${waitlist_ids[0]}
    ${len}=  Get Length  ${waitlist_ids}

     
    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    # # sleep  2s
    # ${resp}=  Get Departments
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    

    # ${user_ids}=  Create List

    FOR   ${a}  IN RANGE   10
            
        ${cons_num}    Random Int  min=123456   max=999999
        ${ph1}=  Evaluate  ${HLPUSERNAME2}+${cons_num}
        Set Test Variable  ${ph1${a}}  ${ph1}
        ${firstname}=  generate_firstname
        ${lastname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date
        ${pin}=  get_pincode
                
        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1${a}}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1${a}}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${ph1${a}}  ${countryCodes[0]}  ${ph1${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${uid${a}}  ${resp.json()}

        ${resp}=   Assign provider Waitlist   ${waitlist_ids[${a}]}    ${uid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id   ${waitlist_ids[${a}]} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END


JD-TC-CreateUser -01

    [Documentation]  take 20 waitlist and Create 20 users by branch login and assign each waitlist 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME66}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # clear_queue      ${PUSERNAME66}
    # clear_service    ${PUSERNAME66}
    clear_customer   ${PUSERNAME66}

    ${pid}=  get_acc_id  ${PUSERNAME66}

    # ${up_addons}=   Get upgradable addons
    # Log  ${up_addons.json()}
    # Should Be Equal As Strings    ${up_addons.status_code}   200
    # Set Suite Variable  ${addons}  ${up_addons.json()}  
    # ${addon_list}=  addons_all_license_applicable  ${addons}
    # Log  ${addon_list}
    # Set Suite Variable  ${addon_list}

    # ${resp}=  Add addon  ${addon_list[0][3]['addon_id']}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # # sleep  3s


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    # # sleep  2s
    # ${resp}=  Get Departments
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    

    # ${user_ids}=  Create List

    FOR   ${a}  IN RANGE   20
            
        ${cons_num}    Random Int  min=123456   max=999999
        ${ph1}=  Evaluate  ${HLPUSERNAME2}+${cons_num}
        Set Test Variable  ${ph1${a}}  ${ph1}
        ${firstname}=  generate_firstname
        ${lastname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date
        ${pin}=  get_pincode
                
        ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1${a}}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1${a}}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${ph1${a}}  ${countryCodes[0]}  ${ph1${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${uid${a}}  ${resp.json()}

        ${resp}=   Assign provider Waitlist   ${wid}   ${uid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${wid} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1     personsAhead=0
        Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
        Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
        Should Be Equal As Strings  ${resp.json()['provider']['id']}                   ${uid${a}}
        Should Be Equal As Strings  ${resp.json()['provider']['firstName']}            ${firstname}
        Should Be Equal As Strings  ${resp.json()['provider']['lastName']}             ${lastname}
        Should Be Equal As Strings  ${resp.json()['provider']['mobileNo']}             ${ph1${a}}
        Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
        Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
        Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
        Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
        Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
        Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
        Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
        Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    END

JD-TC-AssignproviderWaitlist-4
    [Documentation]  Assingn waitlist to user here user doesn't have any service and queue
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_queue      ${HLPUSERNAME2}
    # clear_service    ${HLPUSERNAME2}
    # clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${ph1}=  Evaluate  ${HLPUSERNAME2}+1000440007
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${location}=  FakerLibrary.city
    ${state}=  FakerLibrary.state
    ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${ph1}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${ph1}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${ph2}=  Evaluate  ${HLPUSERNAME2}+1000440008
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${location2}=  FakerLibrary.city
    ${state2}=  FakerLibrary.state
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${address2}  ${ph2}  ${dob2}  ${Genderlist[0]}  ${userType[0]}  ${P_Email}${ph2}.${test_mail}  ${location2}  ${state2}  ${dep_id}  ${sub_domain_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AssignproviderWaitlist-UH2
    [Documentation]  Assingn waitlist to user but didn't create any user in this id
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_queue      ${HLPUSERNAME2}
    # clear_service    ${HLPUSERNAME2}
    # clear_customer   ${HLPUSERNAME2}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${ph2}=  Evaluate  ${HLPUSERNAME2}+1000410020
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${ph2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

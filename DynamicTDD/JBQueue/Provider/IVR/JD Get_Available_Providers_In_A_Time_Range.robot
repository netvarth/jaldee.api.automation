*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Library           DateTime
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Test Cases ***


JD-Get_Avaliable_Providers_In_A_Time_Range-1

    [Documentation]  Get Avaliable Providers In A Time Range

    clear_queue      ${PUSERNAME161}
    clear_location   ${PUSERNAME161}
    clear_service    ${PUSERNAME161}
    clear_customer   ${PUSERNAME161}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time  ${tz}  0  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${list2}=  Create List  1  

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    #${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${sTime2}=  db.add_timezone_time  ${tz}  0    11
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  db.add_timezone_time  ${tz}  15  20
    ${schedule_name2}=  FakerLibrary.bs
    ${list2}=  Create List  1  
    ${DAY3}=  db.add_timezone_date  ${tz}  15 

    ${resp}=  Create Provider Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY3}  ${EMPTY}  ${sTime2}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}
    
    ${DAY3}=  db.add_timezone_date  ${tz}  15 
    ${sTime3}=  db.add_timezone_time  ${tz}  16  20
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  db.add_timezone_time  ${tz}  20  25
    ${schedule_name3}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name3}  ${recurringtype[2]}  ${list}  ${DAY2}  ${DAY3}  ${EMPTY}  ${sTime3}  ${eTime3}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}


    ${resp}=    Get all schedules of an account 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT%H:%M:%S
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT%H:%M:%S

    ${resp}=    Get Available Providers In A Time Range    ${datetime1}    ${datetime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-Get_Avaliable_Providers_In_A_Time_Range-2

    [Documentation]  Get Avaliable Providers In A Time Range without creating schedules

    ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get all schedules of an account 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${DAY3}=  db.add_timezone_date  ${tz}  15
    ${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime2}  ${delta}

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT%H:%M:%S
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT%H:%M:%S

    ${resp}=    Get Available Providers In A Time Range    ${datetime1}    ${datetime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-Get_Avaliable_Providers_In_A_Time_Range-UH1

    [Documentation]  Get Avaliable Providers In A Time Range with another provider details

    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get all schedules of an account 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  "${resp.json()}"   "[]"

    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${DAY3}=  db.add_timezone_date  ${tz}  15
    ${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime2}  ${delta}

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT%H:%M:%S
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT%H:%M:%S

    ${resp}=    Get Available Providers In A Time Range    ${datetime1}    ${datetime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  "${resp.json()}"   "[]"

JD-Get_Avaliable_Providers_In_A_Time_Range-UH2

    [Documentation]  Get Avaliable Providers In A Time Range without login


    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${DAY3}=  db.add_timezone_date  ${tz}  15
    ${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime2}  ${delta}

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT%H:%M:%S
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT%H:%M:%S

    ${resp}=    Get Available Providers In A Time Range    ${datetime1}    ${datetime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}    ${SESSION_EXPIRED}

JD-Get_Avaliable_Providers_In_A_Time_Range-UH3

    [Documentation]  Get Avaliable Providers In A Time Range with last date is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get all schedules of an account 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${DAY3}=  db.add_timezone_date  ${tz}  15
    ${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime2}  ${delta}

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT%H:%M:%S
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT%H:%M:%S

    ${resp}=    Get Available Providers In A Time Range    ${datetime1}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  500

JD-Get_Avaliable_Providers_In_A_Time_Range-UH4

    [Documentation]  Get Avaliable Providers In A Time Range with start date is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get all schedules of an account 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${DAY3}=  db.add_timezone_date  ${tz}  15
    ${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime2}  ${delta}

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT%H:%M:%S
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT%H:%M:%S

    ${resp}=    Get Available Providers In A Time Range    ${empty}    ${datetime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  500

JD-Get_Avaliable_Providers_In_A_Time_Range-UH5

    [Documentation]  Get Avaliable Providers In A Time Range with start date is different format

    ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get all schedules of an account 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${DAY3}=  db.add_timezone_date  ${tz}  15
    ${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime2}  ${delta}

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT%H:%M:%S

    ${resp}=    Get Available Providers In A Time Range    ${datetime1}    ${datetime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  500

JD-Get_Avaliable_Providers_In_A_Time_Range-UH6

    [Documentation]  Get Avaliable Providers In A Time Range with end date is different format

    ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get all schedules of an account 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${DAY3}=  db.add_timezone_date  ${tz}  15
    ${sTime2}=  db.add_timezone_time  ${tz}  11  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime2}  ${delta}

    ${datetime1}    Convert Date    ${DAY2}${sTime2}    result_format=%Y-%m-%dT%H:%M:%S
    ${datetime2}    Convert Date    ${DAY3} ${eTime3}    result_format=%Y-%m-%dT

    ${resp}=    Get Available Providers In A Time Range    ${datetime1}    ${datetime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  500

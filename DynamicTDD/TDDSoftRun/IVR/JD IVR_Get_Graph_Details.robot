*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        IVR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           DateTime
Library           JSONLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***


${cons_verfy_name}    consumer Verfy
${call_back_name}     call back message
${token_Verfy_name}    token Verfy
${consumer_Settings_name}    consumer Settings
${getlanguage_name}    get language
${English_name}    English
${Hindi_name}    Hindi
${Telugu_name}    Telugu
${voice_Mail_name}    voice Mail
${working_hours_name}    working hours
${Emergency_name}    Emergency
${User_Available_name}    User Available
${Error_message_name}    Error Message
${Generate_token_name}    generate token
${Call_User_name}    get User List
${update_Waiting_Time_name}    update Waiting time
${get_Waiting_Time_name}    get Waiting Time
${waiting_option_name}    Waiting Option

${loc}    AP, IN

*** Test Cases ***

JD-TC-Get_IVR_Graph_Details-1

    [Documentation]   Get IVR Graph Details
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  

    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 

    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}  

    ${q_name}=    FakerLibrary.word
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.add_timezone_time  ${tz}  0  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  2  00 
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${callWaitingTime}    Generate random string    1    123456789
    ${token}    FakerLibrary.Random Number
    ${secretKey}    FakerLibrary.Random Number
    ${apiKey}    FakerLibrary.Random Number
    ${companyId}    FakerLibrary.Random Number
    ${publicId}    FakerLibrary.Random Number
    ${languageResetCount}    Generate random string    1    123456789

    ${cons_verfy_id}    FakerLibrary.Random Number
    ${cons_verfy_node_value}    FakerLibrary.Random Number
    ${call_back_id}    FakerLibrary.Random Number
    ${call_back_node_value}    FakerLibrary.Random Number
    ${token_Verfy_id}    FakerLibrary.Random Number
    ${token_Verfy_node_value}    FakerLibrary.Random Number
    ${consumer_Settings_id}    FakerLibrary.Random Number
    ${consumer_Settings_node_value}    FakerLibrary.Random Number
    ${getlanguage_id}    FakerLibrary.Random Number
    ${getlanguage_node_value}    FakerLibrary.Random Number
    ${English_id}    FakerLibrary.Random Number
    ${English_node_value}    FakerLibrary.Random Number
    ${Hindi_id}    FakerLibrary.Random Number
    ${Hindi_node_value}    FakerLibrary.Random Number
    ${Telugu_id}    FakerLibrary.Random Number
    ${Telugu_node_value}    FakerLibrary.Random Number
    ${voice_Mail_id}    FakerLibrary.Random Number
    ${voice_Mail_node_value}    FakerLibrary.Random Number
    ${working_hours_id}    FakerLibrary.Random Number
    ${working_hours_node_value}    FakerLibrary.Random Number
    ${Emergency_id}    FakerLibrary.Random Number
    ${Emergency_node_value}    FakerLibrary.Random Number
    ${User_Available_id}    FakerLibrary.Random Number
    ${User_Available_node_value}    FakerLibrary.Random Number
    ${Error_message_id}    FakerLibrary.Random Number
    ${Error_message_node_value}    FakerLibrary.Random Number
    ${generate_token_id}    FakerLibrary.Random Number
    ${generate_token_node_value}    FakerLibrary.Random Number
    ${Call_users_id}    FakerLibrary.Random Number
    ${Call_users_node_value}    FakerLibrary.Random Number
    ${update_Waiting_Time_id}    FakerLibrary.Random Number
    ${update_Waiting_Time_node_value}    FakerLibrary.Random Number
    ${get_Waiting_Time_id}    FakerLibrary.Random Number
    ${get_Waiting_Time_node_value}    FakerLibrary.Random Number
    ${waiting_option_id}    FakerLibrary.Random Number
    ${waiting_option_node_value}    FakerLibrary.Random Number


    ${consumer_Verfy}    create_ivr_children   ${cons_verfy_id}  ${cons_verfy_name}  ${ivr_language[0]}  ${cons_verfy_node_value}  ${ivr_inputValue[0]}
    ${call_back_message}    create_ivr_children   ${call_back_id}  ${call_back_name}  ${ivr_language[0]}  ${call_back_node_value}  ${ivr_inputValue[1]}
    ${action_token_verify}    ivr_acion_dict    ${token_Verfy_id}  ${token_Verfy_name}  ${ivr_actions[1]}  ${ivr_language[0]}  ${token_Verfy_node_value}  ${consumer_Verfy}  ${call_back_message}

    ${consumer_Settings_True}    create_ivr_children   ${consumer_Settings_id}  ${consumer_Settings_name}  ${ivr_language[0]}  ${consumer_Settings_node_value}  ${ivr_inputValue[0]}
    ${consumer_Settings_False}    create_ivr_children   ${consumer_Settings_id}  ${consumer_Settings_name}  ${ivr_language[0]}  ${consumer_Settings_node_value}  ${ivr_inputValue[1]}
    ${action_consumerVerfy}    ivr_acion_dict    ${cons_verfy_id}  ${cons_verfy_name}  ${ivr_actions[0]}  ${ivr_language[0]}  ${cons_verfy_node_value}  ${consumer_Settings_True}  ${consumer_Settings_False}

    ${English}    create_ivr_children   ${English_id}  ${English_name}  ${ivr_language[0]}  ${English_node_value}  ${ivr_inputValue[0]}
    ${Hindi}    create_ivr_children   ${Hindi_id}  ${Hindi_name}  ${ivr_language[1]}  ${Hindi_node_value}  ${ivr_inputValue[1]}
    ${Telugu}    create_ivr_children   ${Telugu_id}  ${Telugu_name}  ${ivr_language[2]}  ${Telugu_node_value}  ${ivr_inputValue[2]}
    ${action_getlanguage}    ivr_acion_dict    ${getlanguage_id}  ${getlanguage_name}  ${ivr_actions[13]}  ${ivr_language[0]}  ${getlanguage_node_value}  ${English}  ${Hindi}  ${Telugu}

    ${voice_Mail}    create_ivr_children   ${voice_Mail_id}  ${voice_Mail_name}  ${ivr_language[0]}  ${voice_Mail_node_value}  ${ivr_inputValue[0]}
    ${working_hours}    create_ivr_children   ${working_hours_id}  ${working_hours_name}  ${ivr_language[0]}  ${working_hours_node_value}  ${ivr_inputValue[1]}
    ${action_language}    ivr_acion_dict    ${English_id}  ${English_name}  ${ivr_actions[5]}  ${ivr_language[0]}  ${English_node_value}  ${voice_Mail}  ${working_hours}

    ${Emergency}    create_ivr_children   ${Emergency_id}  ${Emergency_name}  ${ivr_language[0]}  ${Emergency_node_value}  ${ivr_inputValue[0]}
    ${User_Available}    create_ivr_children   ${User_Available_id}  ${User_Available_name}  ${ivr_language[0]}  ${User_Available_node_value}  ${ivr_inputValue[1]}
    ${action_checkSchedule}    ivr_acion_dict    ${working_hours_id}  ${working_hours_name}  ${ivr_actions[2]}  ${ivr_language[0]}  ${working_hours_node_value}  ${Emergency}  ${User_Available}

    ${Error_Mesage}    create_ivr_children   ${Error_message_id}  ${Error_message_name}  ${ivr_language[0]}  ${Error_message_node_value}  ${ivr_inputValue[0]}
    ${action_generateToken_Callback}    ivr_acion_dict    ${generate_token_id}  ${Generate_token_name}  ${ivr_actions[2]}  ${ivr_language[0]}  ${generate_token_node_value}  ${Error_Mesage}  ${call_back_message}

    ${action_callUsers}    ivr_acion_dict    ${Call_users_id}  ${Call_User_name}  ${ivr_actions[4]}  ${ivr_language[0]}  ${Call_users_node_value}  ${Error_Mesage}  ${call_back_message}

    ${get_User_List}    create_ivr_children   ${Call_users_id}  ${Call_User_name}  ${ivr_language[0]}  ${Call_users_node_value}  ${ivr_inputValue[1]}
    ${action_update_Waiting_Time}    ivr_acion_dict    ${update_Waiting_Time_id}  ${update_Waiting_Time_name}  ${ivr_actions[12]}  ${ivr_language[0]}  ${update_Waiting_Time_node_value}  ${Error_Mesage}  ${get_User_List}

    ${waiting_option}    create_ivr_children   ${waiting_option_id}  ${waiting_option_name}  ${ivr_language[0]}  ${waiting_option_node_value}  ${ivr_inputValue[0]}
    ${action_getWaitingTime}    ivr_acion_dict    ${get_Waiting_Time_id}  ${get_Waiting_Time_name}  ${ivr_actions[11]}  ${ivr_language[0]}  ${get_Waiting_Time_node_value}  ${waiting_option}  ${get_User_List}

    ${resp}=    IVR_Config_Json    ${action_token_verify}    ${action_consumerVerfy}    ${action_getlanguage}    ${action_language}    ${action_checkSchedule}    ${action_generateToken_Callback}    ${action_callUsers}    ${action_update_Waiting_Time}    ${action_getWaitingTime} 
    Log  ${resp}
    Set Suite Variable  ${ivr_config_data}   ${resp}

    ${resp}=    Create_IVR_Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime}    ${ser_id1}    ${token}    ${secretKey}    ${apiKey}    ${companyId}    ${publicId}    ${languageResetCount}    ${ivr_config_data}   ${bool[1]}   ${bool[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableIvr']}==${bool[0]}
        ${resp}=    enable and disable IVR    ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  db.get_date_by_timezone  ${tz}
    ${call_time}=    db.get_tz_time_secs  ${tz}
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}

    ${resp}=    ivr_user_details    ${acc_id}  ${countryCodes[1]}  ${myoperator_id}  ${PUSERNAME171}  ${countryCodes[1]}${PUSERNAME171}  ${user_id}  ${user_name}

#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}

    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME171}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${in_uid}=  Convert To String  ${incall_uid}

    ${pm}=    after_call_primary_value    ${in_uid}  ${ivr_inputValue[0]}  ${ivr_inputValue[2]}  ${ivr_inputValue[0]}  ${ivr_inputValue[0]}  ${ivr_inputValue[1]}            
    
    ${ring_start_time}=  Get Current date
    ${ring_start_time}=    DateTime.Convert Date    ${ring_start_time}    exclude_millis=yes

    ${last_caller_id}    FakerLibrary.Random Number
    ${agent_id}    FakerLibrary.Random Number
    ${agent_id}=  Convert To String  ${agent_id}
    ${agent_name}    generate_firstname
    Set Test Variable  ${email}  ${agent_name}.${test_mail}
    ${agent_ex}    FakerLibrary.Random Number
    ${numb}    Random Number 	digits=5 
    ${numb}=    Evaluate    f'{${numb}:0>9d}'
    Log  ${numb}
    Set Suite Variable  ${agent_contact}  9${numb}
    Set Test Variable     ${agent_contact_with_cc}    ${countryCodes[0]}${numb}
    
    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${dates}=    Convert Date  ${start1}   result_format=%Y-%m-%d 
    ${start}=    Convert Date  ${start1}   result_format=%H:%M:%S

    ${start_time}=    DateTime.Convert Date    ${start1}   result_format=%s
    ${start_time_in_milli_sec}=    Evaluate    int(float(${start_time}) * 1000)
    ${end_tym} =  Add Time To Date  ${start1}  30 minutes
    ${end}=    DateTime.Convert Date    ${end_tym}    result_format=%H:%M:%S      
    ${end_time}=    DateTime.Convert Date    ${end_tym}    result_format=%s
    ${difference}=    time_difference    ${start}    ${end}
    ${dur_min}=    DateTime.Convert Date    ${dates},${difference}    result_format=%M:%S
    ${timestamp}=    DateTime.Convert Date    ${dates},${difference}    result_format=%s

    ${call_log}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}

    ${file_name}    generate_filename
    ${file_link}    generate_filename
    ${comp_id}    FakerLibrary.Random Number
    ${caller_name}    generate_firstname

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr By reference id    ${incall_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${ivr_uid}   ${resp.json()['uid']}
    
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${created_date2}=    Convert Date  ${start2}   result_format=%Y-%m-%d 

    ${incall_uid02}    FakerLibrary.Random Number



    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid02}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date2}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}

    ${resp}=    innode IVR    ${acc_id}     ${incall_uid02}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid02}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date2}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid02}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME171}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid02}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date2}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid02}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid02}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date2}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid02}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${in_uid}=  Convert To String  ${incall_uid02}

    ${pm}=    after_call_primary_value    ${in_uid}  ${ivr_inputValue[0]}  ${ivr_inputValue[2]}  ${ivr_inputValue[0]}  ${ivr_inputValue[0]}  ${ivr_inputValue[1]}            
    
    ${ring_start_time}=  Get Current date
    ${ring_start_time}=    DateTime.Convert Date    ${ring_start_time}    exclude_millis=yes

    ${last_caller_id}    FakerLibrary.Random Number
    ${agent_id}    FakerLibrary.Random Number
    ${agent_id}=  Convert To String  ${agent_id}
    ${agent_name}    generate_firstname
    Set Test Variable  ${email}  ${agent_name}.${test_mail}
    ${agent_ex}    FakerLibrary.Random Number
    ${numb}    Random Number 	digits=5 
    ${numb}=    Evaluate    f'{${numb}:0>9d}'
    Log  ${numb}
    Set Suite Variable  ${agent_contact}  9${numb}
    Set Test Variable     ${agent_contact_with_cc}    ${countryCodes[0]}${numb}
    

    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${str_tym}=    Convert Date  ${start2}   result_format=%H:%M:%S
    ${start_time2}=    DateTime.Convert Date    ${start2}   result_format=%s
    ${start_time2_in_milli_sec}=    Evaluate    int(float(${start_time2}) * 1000)
    ${end_tym2} =  Add Time To Date  ${start2}  30 minutes
    ${end2}=    DateTime.Convert Date    ${end_tym2}    result_format=%H:%M:%S      
    ${end_time2}=    DateTime.Convert Date    ${end_tym2}    result_format=%s
    ${difference2}=    time_difference    ${str_tym}    ${end2}
    ${dur_min2}=    DateTime.Convert Date    ${start_date},${difference2}    result_format=%M:%S
    ${timestamp2}=    DateTime.Convert Date    ${start_date},${difference2}    result_format=%s

    ${call_log2}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time2}  ${end_time2}  ${timestamp2}  ${ivr_call_status[0]}

    ${file_name2}    generate_firstname
    ${file_link2}    generate_firstname
    ${comp_id2}    FakerLibrary.Random Number
    ${caller_name2}    generate_firstname

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id2}    ${clid_row}    ${caller_name2}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time2}    ${start_time2}    ${start_time2_in_milli_sec}    ${timestamp2}    ${end_time2}    ${difference2}    ${dur_min2}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name2}    ${file_link2}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log2}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${created_date2}    ${created_date}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['labels'][0]}                                 ${created_date2}
    Should Be Equal As Strings  ${resp.json()['labels'][7]}                                 ${created_date} 
    Should Be Equal As Strings  ${resp.json()['datasets'][0]['data'][0]}                    0
    Should Be Equal As Strings  ${resp.json()['datasets'][1]['data'][0]}                    0


JD-TC-Get_IVR_Graph_Details-2 

    [Documentation]   Get IVR Graph Details with a particular date range
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${start_date}    ${CUR_DAY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['labels'][0]}                                 ${start_date}
    Should Be Equal As Strings  ${resp.json()['labels'][7]}                                 ${CUR_DAY}  
    Should Be Equal As Strings  ${resp.json()['datasets'][0]['data'][0]}                    0
    Should Be Equal As Strings  ${resp.json()['datasets'][1]['data'][0]}                     0

JD-TC-Get_IVR_Graph_Details-UH1

    [Documentation]   Get IVR Graph Details without login
     
    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${start_date}    ${CUR_DAY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Get_IVR_Graph_Details-UH2 

    [Documentation]   Get IVR Graph Details with another provider login
    
    # clear_queue      ${PUSERNAME14}
    # clear_location   ${PUSERNAME14}
    # clear_service    ${PUSERNAME14}
    clear_customer   ${PUSERNAME14}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME14}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${start_date}    ${CUR_DAY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['labels'][0]}                                 ${start_date}
    Should Be Equal As Strings  ${resp.json()['labels'][7]}                                 ${CUR_DAY}  
    Should Be Equal As Strings  ${resp.json()['datasets'][0]['data'][0]}                    0
    Should Be Equal As Strings  ${resp.json()['datasets'][1]['data'][0]}                     0

JD-TC-Get_IVR_Graph_Details-UH3

    [Documentation]   Get IVR Graph Details where Report date category is different
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[4]}   ${start_date}    ${CUR_DAY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['labels'][0]}                                 ${start_date}
    Should Be Equal As Strings  ${resp.json()['labels'][7]}                                 ${CUR_DAY}  
    Should Be Equal As Strings  ${resp.json()['datasets'][0]['data'][0]}                    0
    Should Be Equal As Strings  ${resp.json()['datasets'][1]['data'][0]}                     0

JD-TC-Get_IVR_Graph_Details-UH4

    [Documentation]   Get IVR Graph Details where start date given null
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${SPACE}    ${CUR_DAY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Get_IVR_Graph_Details-UH5

    [Documentation]   Get IVR Graph Details where start date is empty
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${empty}    ${CUR_DAY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Get_IVR_Graph_Details-UH6

    [Documentation]   Get IVR Graph Details where end date is null
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${start_date}    ${SPACE}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Get_IVR_Graph_Details-UH7

    [Documentation]   Get IVR Graph Details where end date is empty
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start1} =  Convert Date  ${start1}   result_format=%Y-%m-%d %H:%M:%S.%f
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
    ${start_date}=    Convert Date  ${start2}   result_format=%Y-%m-%d 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${start_date}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Get_IVR_Graph_Details-UH8

    [Documentation]   Get IVR Graph Details where date format is different
    
    # clear_queue      ${PUSERNAME171}
    # clear_location   ${PUSERNAME171}
    # clear_service    ${PUSERNAME171}
    clear_customer   ${PUSERNAME171}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME171}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Account Settings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${start1}    ${resp.json()}
    ${start2}=    DateTime.Add Time To Date    ${start1}    -7 days
  

    ${resp}=    Get IVR Graph Details  ${Report_Date_Category[5]}   ${start2}    ${start1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
   
   
    



    

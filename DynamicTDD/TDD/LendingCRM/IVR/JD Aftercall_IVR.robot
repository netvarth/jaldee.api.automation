*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        IVR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           DateTime
Library           JSONLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
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
${diff}     3000

${loc}    AP, IN

*** Test Cases ***

JD-TC-Aftercall_IVR-1

    [Documentation]   Aftercall IVR
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    Set Test Variable  ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
   
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Test variable  ${lic2}  ${highest_package[0]}

    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

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

    ${resp}=    Create_IVR_Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime}    ${ser_id1}    ${token}    ${secretKey}    ${apiKey}    ${companyId}    ${publicId}    ${languageResetCount}    ${ivr_config_data}  ${bool[1]}   ${bool[1]}
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
    Set Suite Variable    ${incall_id} 
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  db.get_date_by_timezone  ${tz}
    ${call_time}=    db.get_tz_time_secs  ${tz}
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Suite Variable     ${clid_row}    ${countryCodes[0]}${clid}

    ${resp}=    ivr_user_details    ${acc_id}  ${countryCodes[1]}  ${myoperator_id}  ${PUSERNAME151}  ${countryCodes[1]}${PUSERNAME151}  ${user_id}  ${user_name}

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
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME151}
    
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
    Set Suite Variable   ${pm}

    ${ring_start_time}=  Get Current date
    ${ring_start_time}=    DateTime.Convert Date    ${ring_start_time}    exclude_millis=yes
    Set Suite Variable  ${ring_start_time}

    ${last_caller_id}    FakerLibrary.Random Number
    Set Suite Variable  ${last_caller_id}
    ${agent_id}    FakerLibrary.Random Number
    ${agent_id}=  Convert To String  ${agent_id}
    Set Suite Variable  ${agent_id}
    ${agent_name}    generate_firstname
    Set Suite Variable  ${agent_name} 
    Set Suite Variable  ${email}  ${agent_name}.${test_mail}
    ${agent_ex}    FakerLibrary.Random Number
    Set Suite Variable  ${agent_ex}
    ${numb}    Random Number 	digits=5 
    ${numb}=    Evaluate    f'{${numb}:0>9d}'
    Log  ${numb}
    Set Suite Variable  ${agent_contact}  9${numb}
    Set Suite Variable     ${agent_contact_with_cc}    ${countryCodes[0]}${numb}
    
    ${dates}=    db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${dates}
    ${start}=    Get Current Date    result_format=%H:%M:%S
    Set Suite Variable   ${start}
    ${start1}=    Get Current Date
    Set Suite Variable   ${start1}
    ${start_time}=    DateTime.Convert Date    ${start1}   result_format=%s
    Set Suite Variable   ${start_time}
    ${start_time_in_milli_sec}=    Evaluate    int(float(${start_time}) * 1000)
    Set Suite Variable   ${start_time_in_milli_sec}

    ${end_tym} =  Add Time To Date  ${start1}  30 minutes
    ${end}=    DateTime.Convert Date    ${end_tym}    result_format=%H:%M:%S      
    ${end_time}=    DateTime.Convert Date    ${end_tym}    result_format=%s
    Set Suite Variable   ${end_time}

    ${difference}=    time_difference    ${start}    ${end}
    Set Suite Variable   ${difference} 
    ${dur_min}=    DateTime.Convert Date    ${dates},${difference}    result_format=%M:%S
    Set Suite Variable  ${dur_min} 
    ${timestamp}=    DateTime.Convert Date    ${dates},${difference}    result_format=%s
    Set Suite Variable   ${timestamp}

    ${call_log}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log}  


    ${file_name}    generate_filename
    Set Suite Variable   ${file_name} 
    ${file_link}    generate_filename
    Set Suite Variable   ${file_link}
    ${comp_id}    FakerLibrary.Random Number
    Set Suite Variable   ${comp_id} 
    ${caller_name}    generate_firstname
    Set Suite Variable   ${caller_name} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-2

    [Documentation]   Aftercall IVR incall id is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${empty}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-3

    [Documentation]   Aftercall IVR Call Souce is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${empty}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-4

    [Documentation]   Aftercall IVR Company id is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${empty}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-5

    [Documentation]   Aftercall IVR Caller number is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${empty}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-6

    [Documentation]   Aftercall IVR Caller name is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${empty}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-7

    [Documentation]   Aftercall IVR Caller number(formatted) is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${empty}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-8

    [Documentation]   Aftercall IVR Country code is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${empty}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-9

    [Documentation]   Aftercall IVR Call location is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${empty}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-10

    [Documentation]   Aftercall IVR Log time stamp and start time is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${empty}    ${empty}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-11

    [Documentation]   Aftercall IVR Log timestamp (unix epoch) in milliseconds is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${empty}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-12

    [Documentation]   Aftercall IVR diff b/w call end time and start time in seconds is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${empty}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-13

    [Documentation]   Aftercall IVR Call end time is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-14

    [Documentation]   Aftercall IVR Call duration (hh:mm:ss) is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${empty}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-15

    [Documentation]   Aftercall IVR Call duration (in minutes) is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-16

    [Documentation]   Aftercall IVR Call Log type is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${empty}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-17

    [Documentation]   Aftercall IVR Call event type is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${empty}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-18

    [Documentation]   Aftercall IVR file name and file type is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${empty}    ${empty}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-19

    [Documentation]   Aftercall IVR Notification Status is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${empty}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    
JD-TC-Aftercall_IVR-UH1

    [Documentation]   Aftercall IVR account id is different 
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id1}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH2

    [Documentation]   Aftercall IVR Callers number(raw) is given as wrong
    #Callers number(raw) is not considering from dev
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH3

    [Documentation]   Aftercall IVR Caller number(formatted) is given as wrong
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid_row}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH4

    [Documentation]   Aftercall IVR Country code is invalid
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[2]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH5

    [Documentation]   Aftercall IVR Log difference between start time and end time is different
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${diff}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH6

    [Documentation]   Aftercall IVR Call Log type is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${empty}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Aftercall_IVR-UH7

    [Documentation]   Aftercall IVR Call event type is different
    #Aftercall IVR Call event type is different is different
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[2]}    ${ivr_inputValue[2]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH8

    [Documentation]   Aftercall IVR Notification status is different
    #Notification status is not considering from dev

    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[4]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    
JD-TC-Aftercall_IVR-UH9

    [Documentation]   Aftercall IVR Call log ring start time is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${empty}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH10

    [Documentation]   Aftercall IVR call cancelled
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[2]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH11

    [Documentation]   Aftercall IVR agent id is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${empty}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH12

    [Documentation]   Aftercall IVR agent name is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${empty}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH13

    [Documentation]   Aftercall IVR email is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${empty}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH14

    [Documentation]   Aftercall IVR agent contanct number is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${empty}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH15

    [Documentation]   Aftercall IVR agent contanct number with country code is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${empty}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Aftercall_IVR-UH16

    [Documentation]   Aftercall IVR agent call start time and end time is empty
    
    # clear_queue      ${PUSERNAME151}
    # clear_location   ${PUSERNAME151}
    # clear_service    ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable   ${acc_id} 

    ${acc_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_id1} 

     ${call_log1}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${empty}  ${empty}  ${timestamp}  ${ivr_call_status[0]}
    Set Suite Variable   ${call_log1}  

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${empty}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}   ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[4]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log1}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422



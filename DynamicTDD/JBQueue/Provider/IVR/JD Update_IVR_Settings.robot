*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        IVR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
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

JD-TC-Update_IVR_Settings-1

    [Documentation]   Update IVR Settings
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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
    Set Suite Variable   ${languageResetCount}

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

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-2

    [Documentation]   Update IVR Settingswithout creating ivr settings
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-3

    [Documentation]   Update IVR Settings where call waiting time is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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


    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${empty}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-4

    [Documentation]   Update IVR Settings where sample service is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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



    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${empty}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-5

    [Documentation]   Update IVR Settings where token is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${empty}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-6

    [Documentation]   Update IVR Settings where secret key is empty 
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${empty}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-7

    [Documentation]   Update IVR Settings where api key is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${empty}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-8

    [Documentation]   Update IVR Settings where token is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${empty}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-9

    [Documentation]   Update IVR Settings where public id  is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${empty}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update_IVR_Settings-10

    [Documentation]   Update IVR Settings where Language reset count  is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${empty}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Update_IVR_Settings-UH1

    [Documentation]   Update IVR Settings with another provider login
    
    clear_queue      ${PUSERNAME14}
    clear_location   ${PUSERNAME14}
    clear_service    ${PUSERNAME14}
    clear_customer   ${PUSERNAME14}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME14}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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


    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
     Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.content}    ${empty}
JD-TC-Update_IVR_Settings-UH2

    [Documentation]   Update IVR Settings without login
    
    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-Update_IVR_Settings-UH3

    [Documentation]   Update IVR Settings where ivr call priority is low
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[2]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${ivr_config_data}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Update_IVR_Settings-UH4

    [Documentation]   Update IVR Settings where ivr_config_data  is empty
    
    clear_queue      ${PUSERNAME179}
    clear_location   ${PUSERNAME179}
    clear_service    ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 

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

    
    ${callWaitingTime2}    Generate random string    1    123456789
    ${token2}    FakerLibrary.Random Number
    ${secretKey2}    FakerLibrary.Random Number
    ${apiKey2}    FakerLibrary.Random Number
    ${companyId2}    FakerLibrary.Random Number
    ${publicId2}    FakerLibrary.Random Number

    ${resp}=    Update IVR Settings    ${acc_id}    ${ivr_callpriority[0]}    ${callWaitingTime2}    ${ser_id2}    ${token2}    ${secretKey2}    ${apiKey2}    ${companyId2}    ${publicId2}    ${languageResetCount}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=    Get IVR Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



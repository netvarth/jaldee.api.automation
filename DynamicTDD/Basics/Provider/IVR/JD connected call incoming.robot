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


*** Test Cases ***

JD-TC-Incall_IVR-1

    [Documentation]   Incall IVR
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 


    ${CUR_DAY}=  get_date
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
    ${strt_time}=   add_time  0  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_time  2  00 
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

    ${resp}=  Get Accountsettings  
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
    ${created_date}=  get_date
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}

    ${resp}=    ivr_user_details    ${acc_id}  ${countryCodes[1]}  ${myoperator_id}  ${PUSERNAME152}  ${countryCodes[1]}${PUSERNAME152}  ${user_id}  ${user_name}

#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${current_time}=    Get Current Date
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
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
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


JD-TC-Incall_IVR-2

    [Documentation]   Incall IVR-Work Flow change
    #  Work flow change will works here-From dev
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answerd    .......
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}


    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
#..........   Dialling users   ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
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

JD-TC-Incall_IVR-3

    [Documentation]   Given Past date on Incoming call on server
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${Past_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422

    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
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

JD-TC-Incall_IVR-UH1

    [Documentation]   Passing different account id
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422

    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
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

JD-TC-Incall_IVR-UH2

    [Documentation]   Passing empty incall uid on "Incoming call on server" 
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${empty}    $${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_UID}


    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.resp.json()}  ${INVALID_UID}
    
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

JD-TC-Incall_IVR-UH3

    [Documentation]   Passing empty reference id on "Incoming call on server" 
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${empty}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200              
    # Reference id is not checking here from dev


    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
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

JD-TC-Incall_IVR-UH4

    [Documentation]   Incall IVR with another provider login
    
 

    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${user_id1}    ${resp.json()['id']}
    Set Test Variable    ${user_name1}    ${resp.json()['userName']}


   
    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${ IVR_SETTING_NOt_FOUND}"

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${ IVR_SETTING_NOt_FOUND}"

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_USER}"
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${ IVR_SETTING_NOt_FOUND}"


#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${ IVR_SETTING_NOt_FOUND}"

JD-TC-Incall_IVR-UH5

    [Documentation]   Incall IVR with consumer login
    
 

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${user_id1}    ${resp.json()['id']}
    Set Test Variable    ${user_name1}    ${resp.json()['userName']}

    ${acc_id_consumer}=  get_acc_id  ${CUSERNAME6}
    Set Suite Variable   ${acc_id_consumer} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Incall_IVR-UH6

    [Documentation]   Incall IVR without login


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${empty}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   


    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
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

JD-TC-Incall_IVR-UH7

    [Documentation]   Passing empty call state id on "Incoming call on server" 
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${empty}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${Past_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ INVALID_STATUS}
   
   


    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_UID}"

    
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

JD-TC-Incall_IVR-UH8

    [Documentation]   Passing empty call time on Incoming call on server
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${future_date}=     add_date  +10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${empty}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422

    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${empty}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${empty}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${empty}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Incall_IVR-UH9

    [Documentation]   Given Future date on Incoming call on server
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${future_date}=     add_date  +10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${future_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422

    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${future_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${future_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${future_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Incall_IVR-UH10

    [Documentation]   Passing empty reference id on "Incoming call on server" 
    
    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${empty}    ${company_id}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   


    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
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

JD-TC-Incall_IVR-UH11

    [Documentation]   Incall IVR with empty company id
    
 

    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${empty}  ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${empty}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${empty}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${empty}    ${clid_row}   ${clid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Incall_IVR-UH12

    [Documentation]   Incall IVR with empty client number(with country code)
    
 

    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_id}    ${reference_id}    ${company_id}  ${empty}   ${clid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_PHONE}


    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${empty}   ${clid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${empty}   ${clid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_ids}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${empty}   ${clid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    innode IVR    ${acc_ids}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${clid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Incall_IVR-UH13

    [Documentation]   Passing invalid client number
    
 

    clear_queue      ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_service    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}

    ${resp}=  ProviderLogin  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable   ${acc_id} 

    ${acc_ids}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable   ${acc_ids} 

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 


    ${myoperator_id}    FakerLibrary.Random Number
    ${incall_id}    FakerLibrary.Random Number
    ${incall_uid}    FakerLibrary.Random Number
    ${reference_id}    FakerLibrary.Random Number
    ${company_id}    FakerLibrary.Random Number
    ${created_date}=  get_date
    ${Past_date}=     add_date  -10
    ${call_time}=    db.get_time_secs
    ${cclid}    Random Number 	digits=2 
    ${cclid}=    Evaluate    f'{${cclid}:0>9d}'
    Log  ${cclid}
    Set Suite Variable  ${cclid}  ${cclid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${cclid}
    ${cons_verfy_node_value}    FakerLibrary.Random Number

    
#.......   Incoming call on server    ..........

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_id}    ${reference_id}    ${company_id}  ${clid_row}   ${cclid}    ${empty}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}   ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_PHONE}


    ${current_time}=    Get Current Date
    ${current_time}=    Get Current Date    result_format=%s
    Log    Current Time: ${current_time}
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${cclid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ........  dialing users    .......

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${cclid}    ${empty}    ${ivr_inputValue[5]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${cclid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#........  user answered    ........
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME152}
    
    ${user}=    Create List    ${clid_user}
    ${user}=    json.dumps    ${user}

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${cclid}    ${empty}    ${ivr_inputValue[6]}    ${ivr_inputValue[1]}    ${empty}    ${user}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${cclid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


#.......  call finished      .........                                                                                                                                                                                                                                                                                                   

    ${resp}=    Incall IVR    ${acc_id}     ${incall_id}    ${incall_uid}    ${reference_id}    ${company_id}    ${clid_row}   ${cclid}    ${empty}    ${ivr_inputValue[2]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${created_date}    ${call_time}    ${empty}    ${NONE}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    
    ${resp}=    innode IVR    ${acc_id}     ${incall_uid}    ${cons_verfy_node_value}    ${current_time}    ${cclid}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
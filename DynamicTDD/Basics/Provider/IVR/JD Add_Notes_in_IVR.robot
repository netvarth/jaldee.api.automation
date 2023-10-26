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
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${pdffile}     /ebs/TDD/sample.pdf
${txtfile}     /ebs/TDD/numbers.txt
${excelfile}   /ebs/TDD/sampleqnr.xlsx
${jpgfile}     /ebs/TDD/small.jpg
${pngfile}     /ebs/TDD/upload.png
${shfile}     /ebs/TDD/example.sh


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
${file_size_large}      300000

${loc}    AP, IN
${order}    0
*** Test Cases ***

JD-TC-Add_Notes_in_IVR-1

    [Documentation]   Add notes in IVR
    
    clear_queue      ${PUSERNAME150}
    # clear_location   ${PUSERNAME150}
    clear_service    ${PUSERNAME150}
    clear_customer   ${PUSERNAME150}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${acc_id}=  get_acc_id  ${PUSERNAME150}
    Set Suite Variable   ${acc_id} 

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

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
    ${created_date}=  db.get_date_by_timezone  ${tz}
    ${call_time}=    db.get_tz_time_secs  ${tz}
    ${clid}    Random Number 	digits=5 
    ${clid}=    Evaluate    f'{${clid}:0>9d}'
    Log  ${clid}
    Set Suite Variable  ${clid}  9${clid}
    Set Test Variable     ${clid_row}    ${countryCodes[0]}${clid}

    ${resp}=    ivr_user_details    ${acc_id}  ${countryCodes[1]}  ${myoperator_id}  ${PUSERNAME150}  ${countryCodes[1]}${PUSERNAME150}  ${user_id}  ${user_name}

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
    
    ${clid_user}=    Convert To String    ${countryCodes[1]}${PUSERNAME150}
    
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
    ${agent_name}    FakerLibrary.firstName
    Set Test Variable  ${email}  ${agent_name}.${test_mail}
    ${agent_ex}    FakerLibrary.Random Number
    ${numb}    Random Number 	digits=5 
    ${numb}=    Evaluate    f'{${numb}:0>9d}'
    Log  ${numb}
    Set Suite Variable  ${agent_contact}  9${numb}
    Set Test Variable     ${agent_contact_with_cc}    ${countryCodes[0]}${numb}
    
    ${dates}=    db.get_date_by_timezone  ${tz}
    ${start}=    Get Current Date    result_format=%H:%M:%S
    ${start1}=    Get Current Date
    ${start_time}=    DateTime.Convert Date    ${start1}   result_format=%s
    ${start_time_in_milli_sec}=    Evaluate    int(float(${start_time}) * 1000)

    ${end_tym} =  Add Time To Date  ${start1}  30 minutes
    ${end}=    DateTime.Convert Date    ${end_tym}    result_format=%H:%M:%S      
    ${end_time}=    DateTime.Convert Date    ${end_tym}    result_format=%s

    ${difference}=    time_difference    ${start}    ${end}
    ${dur_min}=    DateTime.Convert Date    ${dates},${difference}    result_format=%M:%S
    ${timestamp}=    DateTime.Convert Date    ${dates},${difference}    result_format=%s

    ${call_log}=    after_call_log_details      ${ring_start_time}  ${ivr_dial_string[0]}  ${last_caller_id}  ${agent_id}  ${agent_name}  ${email}  ${agent_ex}  ${agent_contact}  ${agent_contact_with_cc}  ${ivr_inputValue[1]}  ${start_time}  ${end_time}  ${timestamp}  ${ivr_call_status[0]}

    ${file_name}    FakerLibrary.firstName
    ${file_link}    FakerLibrary.firstName
    ${comp_id}    FakerLibrary.Random Number
    ${caller_name}    FakerLibrary.firstName

    ${resp}=    Aftercall IVR    ${acc_id}    ${incall_id}    ${ivr_inputValue[1]}    ${comp_id}    ${clid_row}    ${caller_name}    ${clid}    ${countryCodes[0]}    ${loc}    ${start_time}    ${start_time}    ${start_time_in_milli_sec}    ${timestamp}    ${end_time}    ${difference}    ${dur_min}    ${ivr_inputValue[1]}    ${ivr_inputValue[1]}    ${file_name}    ${file_link}    ${ivr_inputValue[0]}    ${ivr_inputValue[1]}    ${empty}    ${empty}    ${pm}    ${empty}    ${call_log}    ${ivr_inputValue[0]}    ${empty}    ${empty}    ${empty}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr By reference id    ${incall_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${ivruid}    ${resp.json()['uid']}   
    Set Suite Variable    ${ivrconsumerId}     ${resp.json()['consumerId']}
    
    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption3}
    ${file_name}    Evaluate    __import__('os').path.basename('${pdffile}')
    Set Suite Variable  ${file_name}
    ${file_size}    Get File Size    ${pdffile}
    Set Suite Variable    ${file_size}


    ${resp1}=  db.getType   ${txtfile} 
    Log  ${resp1}
    ${fileType4}=  Get From Dictionary       ${resp1}    ${txtfile} 
    Set Suite Variable    ${fileType4}
    ${file_name_txt}    Evaluate    __import__('os').path.basename('${txtfile}')
    Set Suite Variable  ${file_name_txt}
    ${file_size_txt}    Get File Size    ${txtfile}
    Set Suite Variable    ${file_size_txt}

    ${resp2}=  db.getType   ${excelfile} 
    Log  ${resp2}
    ${fileType5}=  Get From Dictionary       ${resp2}    ${excelfile} 
    Set Suite Variable    ${fileType5}
    ${file_name_excel}    Evaluate    __import__('os').path.basename('${excelfile}')
    Set Suite Variable  ${file_name_excel}
    ${file_size_excel}    Get File Size    ${excelfile}
    Set Suite Variable    ${file_size_excel}

    ${resp2}=  db.getType   ${jpgfile} 
    Log  ${resp2}
    ${fileType6}=  Get From Dictionary       ${resp2}    ${jpgfile} 
    Set Suite Variable    ${fileType6}
    ${file_name_jpg}    Evaluate    __import__('os').path.basename('${jpgfile}')
    Set Suite Variable  ${file_name_jpg}
    ${file_size_jpg}    Get File Size    ${jpgfile}
    Set Suite Variable    ${file_size_jpg}

    ${resp2}=  db.getType   ${pngfile} 
    Log  ${resp2}
    ${fileType7}=  Get From Dictionary       ${resp2}    ${pngfile} 
    Set Suite Variable    ${fileType7}
    ${file_name_png}    Evaluate    __import__('os').path.basename('${pngfile}')
    Set Suite Variable  ${file_name_png}
    ${file_size_png}    Get File Size    ${pngfile}
    Set Suite Variable    ${file_size_png}

    ${resp2}=  db.getType   ${shfile} 
    Log  ${resp2}
    ${fileType8}=  Get From Dictionary       ${resp2}    ${shfile} 
    Set Suite Variable    ${fileType8}
    ${file_name_sh}    Evaluate    __import__('os').path.basename('${shfile}')
    Set Suite Variable  ${file_name_sh}
    ${file_size_sh}    Get File Size    ${shfile}
    Set Suite Variable    ${file_size_sh}

    ${attachment}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}
    Set Suite Variable    ${attachment}
    
    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['notes']}    []

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['notes'][0]['note']}                            ${note}
    Should Be Equal As Strings    ${resp.json()[0]['notes'][0]['attachments'][0]['owner']}         ${user_id}
    Should Be Equal As Strings    ${resp.json()[0]['notes'][0]['attachments'][0]['fileName']}      ${file_name}
    Should Be Equal As Strings    ${resp.json()[0]['notes'][0]['attachments'][0]['caption']}       ${caption3}
    Should Contain                ${resp.json()[0]['notes'][0]['attachments'][0]['fileType']}      ${fileType3}
    Should Be Equal As Strings    ${resp.json()[0]['notes'][0]['attachments'][0]['ownerType']}     ${ownerType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['notes'][0]['attachments'][0]['ownerName']}     ${user_name}
    Should Be Equal As Strings    ${resp.json()[0]['notes'][0]['attachments'][0]['uid']}           ${ivruid}

JD-TC-Add_Notes_in_IVR-2

    [Documentation]   Add notes in IVR where note is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Add Notes To IVR    ${ivruid}    ${empty}    ${attachment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['notes'][1]['note']}      ${empty}


JD-TC-Add_Notes_in_IVR-3

    [Documentation]   Add notes in IVR where attachment userid is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${empty}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-4

    [Documentation]   Add notes in IVR where attachment owner type is invalid
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[1]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-5

    [Documentation]   Add notes in IVR where attachment owner name is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${empty}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-6

    [Documentation]   Add notes in IVR where attachment file name is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${empty}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}     ${FILE_NAME_NOT_FOUND}

JD-TC-Add_Notes_in_IVR-7

    [Documentation]   Add notes in IVR where attachment file size is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${empty}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}     ${FILE_SIZE_ERROR}

JD-TC-Add_Notes_in_IVR-8

    [Documentation]   Add notes in IVR where attachment caption is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${empty}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-9

    [Documentation]   Add notes in IVR where attachment action is remove
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[1]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Ivr Details By Filter  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-10

    [Documentation]   Add notes in IVR where attachment uid is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${empty}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-11

    [Documentation]   Add notes in IVR where attachment order is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${empty}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-12

    [Documentation]   Add notes in IVR where attachment file size is large
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size_large}  caption=${caption3}  fileType=${fileType3}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-13

    [Documentation]   Add notes in IVR where attachment file type is document
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name_txt}  fileSize=${file_size_txt}  caption=${caption3}  fileType=${fileType4}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-14

    [Documentation]   Add notes in IVR where attachment file type is excel
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name_excel}  fileSize=${file_size_excel}  caption=${caption3}  fileType=${fileType5}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-15

    [Documentation]   Add notes in IVR where attachment file type is jpg
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name_jpg}  fileSize=${file_size_jpg}  caption=${caption3}  fileType=${fileType6}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Add_Notes_in_IVR-16

    [Documentation]   Add notes in IVR where attachment file type is png
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name_png}  fileSize=${file_size_png}  caption=${caption3}  fileType=${fileType7}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-Add_Notes_in_IVR-UH1

    [Documentation]   Add notes in IVR where attachment file type is empty
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name}  fileSize=${file_size}  caption=${caption3}  fileType=${empty}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}     ${FILE_TYPE_NOT_FOUND}


JD-TC-Add_Notes_in_IVR-UH2

    [Documentation]   Add notes in IVR where ivr id is invalid
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${invuid}=    FakerLibrary.Random Number

    ${resp}=    Add Notes To IVR    ${invuid}    ${note}    ${attachment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}     ${INVALID_UID}

JD-TC-Add_Notes_in_IVR-UH3

    [Documentation]   Add notes in IVR with another provider login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}     ${NO_PERMISSION}

JD-TC-Add_Notes_in_IVR-UH4

    [Documentation]   Add notes in IVR with consumer login
    
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}     ${NoAccess}

JD-TC-Add_Notes_in_IVR-UH5

    [Documentation]   Add notes in IVR without login

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Add_Notes_in_IVR-UH6

    [Documentation]   Add notes in IVR where attachment file type is sh
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment1}=   Create Dictionary   action=${LoanAction[0]}  owner=${user_id}  ownerType=${ownerType[0]}  ownerName=${user_name}  fileName=${file_name_sh}  fileSize=${file_size_sh}  caption=${caption3}  fileType=${fileType8}  uid=${ivruid}  order=${order}

    ${resp}=    Add Notes To IVR    ${ivruid}    ${note}    ${attachment1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


   



 


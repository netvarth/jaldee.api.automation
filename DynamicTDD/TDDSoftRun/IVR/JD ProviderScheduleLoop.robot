*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           RequestsLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


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

@{service_names}



*** Test Cases ***


JD-TC-Create_Provider_Schedule-1

    [Documentation]  Create Provider Schedule


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    # Set Suite Variable  ${user_id}  ${resp.json()['id']}
    # Set Suite Variable    ${user_name}  ${resp.json()['userName']}
    # Set Test Variable   ${lic_id}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}



    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Active License


    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # #Set Suite Variable  ${lic2}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    # Should Be Equal As Strings    ${resp.status_code}  422

    ${resp}=  Get Departments
    Log  ${resp.content}
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END
    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId}=  Create Sample Location
    # ELSE
    #     Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
    #     Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    # END

       ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200

       
       # ${resp}=  GET Account License details     ${acc_id}
       # Log  ${resp.content}
       # Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Addon Transactions details     ${acc_id}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Account Addon details  ${acc_id}  
       Log  ${resp.content} 
       Should be equal as strings  ${resp.status_code}       200

# --------------------------  Multi User - 1000 Count ---------------------
        ${resp}=   Get Addons Metadata For Superadmin
	    Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable    ${addon_id}      ${resp.json()[6]['addons'][4]['addonId']}
        Set Suite Variable    ${addon_name}      ${resp.json()[6]['addons'][4]['addonName']}
        Log   ${addon_id}

        ${resp}=  Add Addons details  ${acc_id}  ${addon_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Addon Transactions details     ${acc_id}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200

	${resp}=  Get Account Addon details  ${acc_id}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${locId}  ${resp}  

    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 

    # clear_service  ${PUSERNAME101} 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=100   max=100
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${ser_name1}  ${desc}  ${ser_durtn}  ${bool[0]}  ${service_amount}  ${bool[0]}  prePaymentType=${advancepaymenttype[0]}  department=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    # ${resp}=   Create Sample Service  ${ser_name1}
    # Set Suite Variable    ${ser_id1}  ${resp}  
    # ${ser_name2}=   FakerLibrary.word
    # Set Suite Variable    ${ser_name2} 

    # ${resp}=   Create Sample Service  ${ser_name2}
    # Set Suite Variable    ${ser_id2}  ${resp}  

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
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}  ${capacity}  ${locId}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

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

    ${resp}=    IVR_Config_Json    ${action_token_verify}  ${action_consumerVerfy}  ${action_getlanguage}  ${action_language}  ${action_checkSchedule}  ${action_generateToken_Callback}  ${action_callUsers}  ${action_update_Waiting_Time}  ${action_getWaitingTime} 
    Log  ${resp}
    Set Suite Variable  ${ivr_config_data}  ${resp}

    ${resp}=    Create_IVR_Settings    ${acc_id}  ${ivr_callpriority[0]}  ${callWaitingTime}  ${ser_id1}  ${token}  ${secretKey}  ${apiKey}  ${companyId}  ${publicId}  ${languageResetCount}  ${ivr_config_data}  ${bool[1]}  ${bool[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${firstName}=    FakerLibrary.firstName
    ${lastName}=    FakerLibrary.lastName
    Set Suite Variable  ${email}  ${firstName}${C_Email}.${test_mail}


    FOR  ${i}  IN RANGE   500
        ${u_id${i}}=  Create Sample User
        Set Suite Variable  ${u_id${i}}
        ${resp}=  Get User By Id  ${u_id${i}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${BUSER_U1${i}}  ${resp.json()['mobileNo']}
        Set Test Variable  ${userf_name${i}}  ${resp.json()['firstName']}
        Set Test Variable  ${userl_name${i}}  ${resp.json()['lastName']}

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
        Set Test Variable     ${clid_row}  ${countryCodes[0]}${clid}

      


        ${resp}=    ivr_user_details    ${acc_id}  ${countryCodes[1]}  ${myoperator_id}  ${HLPUSERNAME53}  ${countryCodes[1]}${HLPUSERNAME53}  ${u_id${i}}  ${userf_name${i}} ${userl_name${i}} 



        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${DAY2}=  db.add_timezone_date  ${tz}  10      
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime1}=  db.add_timezone_time  ${tz}  0  15
        ${delta}=  FakerLibrary.Random Int  min=10  max=60
        ${eTime1}=  add_two   ${sTime1}  ${delta}
        ${schedule_name}=  FakerLibrary.bs
        ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${u_id${i}}
        Log  ${resp.json()}
        Set Test Variable  ${sch_id}  ${resp.json()}

        ${resp}=  IVR Update User Language    ${u_id${i}}  ${ivr_language[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200


    END



*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Addon
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***
${nods}  0

*** Test Cases ***
JD-TC-Delete addon -1
       [Documentation]   Provider adding 2 Multi User addon,then delete active addon.

       ${resp}=   Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD} 
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}   200

       ${p_id1}=  get_acc_id  ${HLMUSERNAME6}
       Set Suite Variable   ${p_id1}

    
       ${resp}=   Get Business Profile
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

       ${resp}=  View Waitlist Settings
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}    200
       IF  ${resp.json()['filterByDept']}==${bool[0]}
              ${resp}=  Toggle Department Enable
              Log  ${resp.content}
              Should Be Equal As Strings  ${resp.status_code}  200

       END

       ${resp}=  Get Departments
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
       IF   '${resp.content}' == '${emptylist}'
              ${dep_name1}=  FakerLibrary.bs
              ${dep_code1}=   Random Int  min=100   max=999
              ${dep_desc1}=   FakerLibrary.word  
              ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
              Log  ${resp1.content}
              Should Be Equal As Strings  ${resp1.status_code}  200
              Set Suite Variable  ${dep_id}  ${resp1.json()}
       ELSE
              Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
       END

       ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200

       
       # ${resp}=  GET Account License details     ${p_id1}
       # Log  ${resp.content}
       # Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Addon Transactions details     ${p_id1}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Account Addon details  ${p_id1}  
       Log  ${resp.content} 
       Should be equal as strings  ${resp.status_code}       200

# --------------------------  Multi User - 25 Count ---------------------
       ${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id}      ${resp.json()[6]['addons'][0]['addonId']}
	Set Suite Variable    ${addon_name}      ${resp.json()[6]['addons'][0]['addonName']}
       Log   ${addon_id}

       ${resp}=  Add Addons details  ${p_id1}   ${addon_id}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Addon Transactions details     ${p_id1}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200

	${resp}=  Get Account Addon details  ${p_id1}  
	Log  ${resp.content} 
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id} 
	should be equal as strings  ${resp.json()[0]['name']}  ${addon_name}	   	  
	Should Be Equal As Strings  ${resp.status_code}  200

# --------------------------  Multi User - 50 Count ---------------------
       ${resp}=   Get Addons Metadata For Superadmin
	Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200
	Set Suite Variable    ${addon_id1}      ${resp.json()[6]['addons'][1]['addonId']}
	Set Suite Variable    ${addon_name1}      ${resp.json()[6]['addons'][1]['addonName']}
       Log   ${addon_id1}

       ${resp}=  Add Addons details  ${p_id1}   ${addon_id1}
	Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=  Get Addon Transactions details     ${p_id1}
       Log  ${resp.content}
       Should Be Equal As Strings  ${resp.status_code}  200

	${resp}=  Get Account Addon details  ${p_id1}  
	Log  ${resp.content} 
	Should Be Equal As Strings  ${resp.status_code}  200
	should be equal as strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id1} 
	should be equal as strings  ${resp.json()[0]['name']}  ${addon_name1}	  
	Set Suite Variable    ${addon1_id}      ${resp.json()[0]['accountLicId']}
	Set Suite Variable    ${addon2_id}      ${resp.json()[1]['accountLicId']}



       ${resp}=   Delete Not Used AddOn         ${p_id1}    ${addon2_id}
    #    Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=   Month Matrix Cache Task
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=   Get addons auditlog
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       Should Be Equal As Strings  ${resp.json()[1]['licPkgOrAddonId']}  ${addon_id}   
       Should Be Equal As Strings  ${resp.json()[1]['base']}  False
       Should Be Equal As Strings  ${resp.json()[1]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[1]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[1]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[1]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[1]['name']}  ${addon_name}

       Should Be Equal As Strings  ${resp.json()[0]['licPkgOrAddonId']}  ${addon_id1}   
       Should Be Equal As Strings  ${resp.json()[0]['base']}  False
       Should Be Equal As Strings  ${resp.json()[0]['licenseTransactionType']}  New
       Should Be Equal As Strings  ${resp.json()[0]['renewedDays']}  0
       Should Be Equal As Strings  ${resp.json()[0]['type']}  Production
       Should Be Equal As Strings  ${resp.json()[0]['status']}  Active
       Should Be Equal As Strings  ${resp.json()[0]['name']}  ${addon_name1}


JD-TC-Addaddon -UH1
       [Documentation]   Try to delete using addon.

       ${resp}=   Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD} 
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}   200

       ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+577810
       clear_users  ${PUSERNAME_U1}
       Set Suite Variable  ${PUSERNAME_U1}
       ${firstname}=  FakerLibrary.name
       Set Suite Variable  ${firstname}
       ${lastname}=  FakerLibrary.last_name
       Set Suite Variable  ${lastname}
       ${dob}=  FakerLibrary.Date
       Set Suite Variable  ${dob}
       ${pin}=  get_pincode
       ${user_dis_name}=  FakerLibrary.last_name
       Set Suite Variable  ${user_dis_name}
       ${employee_id}=  FakerLibrary.last_name
       Set Suite Variable  ${employee_id}

       ${resp}=   Get License UsageInfo 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200

       FOR   ${a}  IN RANGE   5

              ${PO_Number}    Generate random string    7    0123456789
              ${p_num}    Convert To Integer  ${PO_Number}
              ${PUSERNAME}=  Evaluate  ${PUSERNAME}+${p_num}
              Set Test Variable  ${PUSERNAME${a}}  ${PUSERNAME}

              ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME${a}}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  
              Log   ${resp.json()}
              Should Be Equal As Strings  ${resp.status_code}  200
              Set Suite Variable  ${u_id${a}}  ${resp.json()}

              ${resp}=  Get User By Id      ${u_id${a}}
              Log   ${resp.json()}
              Should Be Equal As Strings      ${resp.status_code}  200

       END

       ${resp}=   Get User Count
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=   Delete Not Used AddOn         ${p_id1}    ${addon1_id}
    #    Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=   Month Matrix Cache Task
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=   Get License UsageInfo 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=   Get addons auditlog
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

JD-TC-Addaddon -UH2
       [Documentation]   Try to delete Used_Up status addon.

       ${resp}=   Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD} 
       Log  ${resp.content}
       Should Be Equal As Strings    ${resp.status_code}   200

       ${resp}=   Get License UsageInfo 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${pin}=  get_pincode
       ${user_dis_name}=  FakerLibrary.last_name

       FOR   ${a}  IN RANGE   96

              ${PO_Number}    Generate random string    7    0123456789
              ${p_num}    Convert To Integer  ${PO_Number}
              ${PUSERNAME}=  Evaluate  ${PUSERNAME}+${p_num}
              Set Test Variable  ${PUSERNAME${a}}  ${PUSERNAME}

              ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME${a}}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  
              Log   ${resp.json()}
              Should Be Equal As Strings  ${resp.status_code}  200
              Set Suite Variable  ${u_id${a}}  ${resp.json()}

              ${resp}=  Get User By Id      ${u_id${a}}
              Log   ${resp.json()}
              Should Be Equal As Strings      ${resp.status_code}  200

       END

       ${resp}=   Get User Count
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=   Delete Not Used AddOn         ${p_id1}    ${addon1_id}
    #    Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=   Month Matrix Cache Task
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200

       ${resp}=   Get License UsageInfo 
       Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=   Get addons auditlog
       Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200


JD-TC-Addaddon -UH3
       [Documentation]   Try to delete with Invalid addon id.

       ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200

       ${resp}=   Delete Not Used AddOn         ${p_id1}    ${pin}
    #    Log   ${resp.json()}
       Should Be Equal As Strings   ${resp.status_code}   200
*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Variables ***
${item1}   ITEM1
${item2}   ITEM2
${item3}   ITEM3
${item4}   ITEM4
${item5}   ITEM5


*** Test Cases ***

JD-TC-Create Item-1

    [Documentation]  Provider Create item taxable is true and false
    ${resp}=  ProviderLogin  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
#     clear_Item  ${PUSERNAME24}
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     Set Suite Variable    ${amount1}
#     ${amount2}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
#     ${resp}=  ProviderLogin  ${PUSERNAME24}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${GST_num}  ${pan_num}=  db.Generate_gst_number  ${Container_id}
#     ${Percentage}    Random Element     [5,12,18,28]  
#     ${resp}=  Update Tax Percentage  ${Percentage}   ${GST_num} 
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${resp}=  Enable Tax
#     Should Be Equal As Strings    ${resp.status_code}   200 
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}    ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
#     ${item2}=   FakerLibrary.Word
#     ${resp}=  Create Item   ${item2}   ${des}   ${description}  ${amount2}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id1}  ${resp.json()}
#     ${resp}=   Get Item By Id  ${id} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Log   ${resp.json()}
#     Verify Response  ${resp}  displayName=${item1}  displayDesc=${description}   shortDesc=${des}   status=${status[0]}   price=${amount1}    taxable=${bool[0]}
#     ${resp}=  Get Item By Id  ${id1}
#     Should Be Equal As Strings  ${resp.status_code}  200    
#     Verify Response   ${resp}  displayName=${item2}   shortDesc=${des}   displayDesc=${description}   status=${status[0]}       price=${amount2}    taxable=${bool[1]}

# JD-TC-Create Item-2

#     [Documentation]   Provider check to create an item with another provider's item name
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${amount3}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  ProviderLogin  ${PUSERNAME4}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount3}    ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
#     ${resp}=   Get Item By Id  ${id} 
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Verify Response  ${resp}  displayName=${item1}  displayDesc=${description}   shortDesc=${des}   status=${status[0]}    price=${amount3}    taxable=${bool[0]}
#     ${resp}=  ProviderLogout
#     Should Be Equal As Strings    ${resp.status_code}    200

# JD-TC-Create Item-UH1

#     [Documentation]  create an item without login
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${amount4}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item3}  ${des}   ${description}  ${amount4}  ${bool[0]} 
#     Should Be Equal As Strings  ${resp.status_code}  419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"      

# JD-TC-Create Item-UH2

#     [Documentation]  Consumer check to create an item
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  Consumer Login   ${CUSERNAME9}  ${PASSWORD}
#     Log  ${resp}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount4}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item3}  ${des}   ${description}  ${amount4}  ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

# JD-TC-Create Item-UH3

#     [Documentation]  Provider create already existing item name
#      ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME24}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}  200   
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}   ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Log  ${resp.json()}
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_SHOULD_BE_UNIQUE}"

# JD-TC-Create Item-3

#     [Documentation]  Check Item limit(only 10 items can create under packageid 1 )

#     ${domresp}=  Get BusinessDomainsConf
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${len}=  Evaluate  ${len}-1
#     ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40003333
#     Set Suite Variable  ${PUSERNAME}
#     Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}   
#     Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${lowest_package}=  get_lowest_license_pkg
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${lowest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  ProviderLogin  ${PUSERNAME}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${length}=  get_item_metrics_value   Item   1
#     Set Suite Variable    ${length}
#     Log  ${length}
#     FOR  ${a}   IN RANGE  ${length} 
        
#         ${des}=  FakerLibrary.Word
#         ${description}=  FakerLibrary.sentence
#         ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#         ${resp}=  Create Item   ${item2}${a}  ${des}   ${description}  ${amount1}    ${bool[0]} 
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${id}  ${resp.json()}
#         ${resp}=   Get Item By Id  ${id} 
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}    displayName=${item2}${a}   shortDesc=${des}   displayDesc=${description}   status=${status[0]}    price=${amount1}    taxable=${bool[0]} 
#     END
#     ${resp}=  Get Items
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  ProviderLogout 
     
# JD-TC-Create Item-UH4

#     [Documentation]  Check Item limit(only 10 items can create under packageid 1,here trying to create one more item without upgrade license )
#     ${resp}=  ProviderLogin  ${PUSERNAME}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     sleep  1s
#     ${resp}=  Get Items
#     Log  ${resp.json()}
#     ${des2}=  FakerLibrary.Word
#     ${description2}=  FakerLibrary.sentence
#     ${amount2}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item4}  ${des2}   ${description2}  ${amount2}    ${bool[0]}  
#     Log  ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${NOT_ALLOWED}"
   
# JD-TC-Create Item-5

#     [Documentation]  Check Item limit(only 50 items can create under packageid 2 )

#     ${resp}=  ProviderLogin  ${PUSERNAME}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=   Get upgradable license
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable  ${pkgid}  ${resp.json()[0]['pkgId']} 
#     Set Test Variable  ${pkgname}  ${resp.json()[0]['pkgName']}
#     ${resp}=  Change License Package  ${pkgid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${len1}=  get_item_metrics_value   Item   2
#     ${len1}=  Evaluate  ${len1}-${length}
#     # ${len1}=  Evaluate  ${len1}-1
#     Log  ${len1}
#     FOR  ${b}   IN RANGE   ${len1} 
#         # ${itm3}=  FakerLibrary.Word
#         ${des3}=  FakerLibrary.Word
#         ${description3}=  FakerLibrary.sentence
#         ${amount3}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#         ${resp}=  Create Item   ${item1}${b}  ${des3}   ${description3}  ${amount3}    ${bool[0]} 
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${id}  ${resp.json()}
#         ${resp}=   Get Item By Id  ${id} 
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  displayName=${item1}${b}   shortDesc=${des3}   displayDesc=${description3}   status=${status[0]}    price=${amount3}    taxable=${bool[0]}
#     END
#     ${resp}=  Get Items
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200


# JD-TC-Create Item-UH5

#     [Documentation]  Check Item limit(only 50 items can create under packageid 2,here trying to create one more item without upgrade license )

#     ${resp}=  ProviderLogin  ${PUSERNAME}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     sleep  1s
#     ${des4}=  FakerLibrary.Word
#     ${description4}=  FakerLibrary.sentence
#     ${amount4}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item5}  ${des4}   ${description4}  ${amount4}    ${bool[0]}  
#     Log  ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${NOT_ALLOWED}"





# *** comment ***
# *** Keywords ***
# itemlow
#     [Arguments]  ${len}
#     ${len}=  get_item_metrics_value   Item   1
#     Log  ${len.json()}
    
#     FOR  ${a}   IN RANGE  ${len} 
#         ${itm}=  FakerLibrary.Word
#         ${des}=  FakerLibrary.Word
#         ${description}=  FakerLibrary.sentence
#         ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#         ${resp}=  Create Item   ${itm}  ${des}   ${description}  ${amount1}    ${bool[0]}   
#         Should Be Equal As Strings  ${resp.status_code}  200
#     END
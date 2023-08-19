*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        FavouriteProvider
Library           Collections
Library           String
Library           json
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py




*** Test Cases ***

JD-TC-RemoveFavouriteProvider-1
      [Documentation]   Remove favourite provider by consumer login
      ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_acc_id  ${PUSERNAME21}
      Set Suite Variable  ${id1}  ${id}
      ${resp}=  Add Favourite Provider  ${id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Remove Favourite Provider  ${id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  List Favourite Provider 
      Should Not Contain   ${resp.json()}  id=${id}     

JD-TC-RemoveFavouriteProvider-2
     [Documentation]  again add a removed provider to favourite list
     ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Add Favourite Provider  ${id1}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Remove Favourite Provider  ${id1}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Add Favourite Provider  ${id1} 
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  List Favourite Provider
     Log  ${resp.json()}
     Verify Response List  ${resp}  0  id=${id1}
     


# JD-TC-RemoveFavouriteProvider-3
#       [Documentation]   Remove favourite provider by a provider switched to a consumer
#       ${resp}=  Consumer Login  ${PUSERNAME26}  ${PASSWORD}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  Add Favourite Provider  ${id1}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  Remove Favourite Provider  ${id1}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  List Favourite Provider
#       Should Not Contain  ${resp.json()}  id=${id1}      



# JD-TC-RemoveFavouriteProvider-4
#      [Documentation]  a provider remove himself from favourite list
#      ${resp}=  Consumer Login  ${PUSERNAME27}  ${PASSWORD}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      ${id}=  get_acc_id  ${PUSERNAME27}
#      ${resp}=  Remove Favourite Provider  ${id}
#      Should Be Equal As Strings  ${resp.status_code}  200
#      Should Not Contain  ${resp.json()}  id=${id}     
       
JD-TC-RemoveFavouriteProvider-UH1
     [Documentation]  Remove favourite provider without login
     ${resp}=  Remove Favourite Provider  ${id1}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-RemoveFavouriteProvider-UH2
     [Documentation]  Remove favourite provider which doesnot exist
     ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${id}=  get_acc_id  ${Invalid_email}
     ${resp}=  Remove Favourite Provider  ${id}
     Should Be Equal As Strings  ${resp.status_code}  422  
     Should Be Equal As Strings  "${resp.json()}"   "${FAVOURITE_PROVIDER_NOT_EXIST}"

JD-TC-RemoveFavouriteProvider-UH3
     [Documentation]  A Consumer is removing another consumers  favourite provider 
     ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Add Favourite Provider  ${id1}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Consumer Logout
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}   200 
     ${resp}=  Remove Favourite Provider  ${id1}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"   "${FAVOURITE_PROVIDER_NOT_EXIST}"


JD-TC-RemoveFavouriteProvider-Remove_test_cases
     ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
     ${resp}=  Remove Favourite Provider  ${id1}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  List Favourite Provider 
     Should Not Contain   ${resp.json()}  id=${id1}
     ${resp}=  Consumer Logout

     ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
     ${resp}=  Remove Favourite Provider  ${id1}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  List Favourite Provider 
     Should Not Contain   ${resp.json()}  id=${id1}
     ${resp}=  Consumer Logout


***Comment***

JD-TC-RemoveFavouriteProvider-UH3
     [Documentation]  Remove favourite provider by provider login
     ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${id}=  get_acc_id  ${PUSERNAME26}
     ${resp}=  Add Favourite Provider  ${id}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Consumer Logout
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  ProviderLogin  ${PUSERNAME27}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}   200 
     ${resp}=  Remove Favourite Provider  ${id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"




              

     

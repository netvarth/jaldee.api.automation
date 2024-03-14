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

JD-TC-ListFavouriteProvider-1
      [Documentation]   List favourite provider by consumer login
      ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_acc_id  ${PUSERNAME20}
      ${resp}=  Add Favourite Provider  ${id}
      Log  ${resp.json()}
      Set Suite Variable  ${id}  ${id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  List Favourite Provider 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${id}   

JD-TC-ListFavouriteProvider-2
      [Documentation]   List more favourite provider by consumer login
      ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id1}=  get_acc_id  ${PUSERNAME21}
      ${resp}=  Add Favourite Provider  ${id1}
      Log  ${resp.json()}
      Set Suite Variable  ${id1}  ${id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  List Favourite Provider 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${id}
      Verify Response List  ${resp}  1  id=${id1} 
               
# JD-TC-ListFavouriteProvider-3
#       [Documentation]   List favourite provider when provider login as consumer
#       ${resp}=  Consumer Login  ${PUSERNAME19}  ${PASSWORD}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${id1}=  get_acc_id  ${PUSERNAME19}
#       ${id2}=  get_acc_id  ${PUSERNAME20}
#       ${resp}=  Add Favourite Provider  ${id2}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  List Favourite Provider 
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Verify Response List  ${resp}  0  id=${id1}
#       Verify Response List  ${resp}  1  id=${id2}

JD-TC-ListFavouriteProvider-UH1
     [Documentation]  List favourite provider without login
     ${resp}=  List Favourite Provider  
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-ListFavouriteProvider-Clear
      ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  List Favourite Provider 
      Log  ${resp.json()}  
      Should Be Equal As Strings  ${resp.status_code}  200
      ${favlen}=  Get Length   ${resp.json()}
      FOR  ${x}  IN RANGE  ${favlen}
            ${pid}=   Set Variable   ${resp.json()[${x}]['id']}
            ${resp1}=  Remove Favourite Provider  ${pid}
            Log  ${resp1.json()}
            Should Be Equal As Strings  ${resp1.status_code}  200
      END
      ${resp}=  Consumer Logout
      Should Be Equal As Strings  ${resp.status_code}  200

      # ${resp}=  Consumer Login  ${PUSERNAME19}  ${PASSWORD}
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  List Favourite Provider 
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # ${favlen}=  Get Length   ${resp.json()}
      # FOR  ${x}  IN RANGE  1  ${favlen}
      #       ${pid}=   Set Variable   ${resp.json()[${x}]['id']}
      #       ${resp1}=  Remove Favourite Provider  ${pid}
      #       Log  ${resp1.json()}
      #       Should Be Equal As Strings  ${resp1.status_code}  200
      # END
      # ${resp}=  Consumer Logout
      # Should Be Equal As Strings  ${resp.status_code}  200

*** Comments ***
JD-TC-ListFavouriteProvider-UH2
     [Documentation]  List favourite provider by provider login
     ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}   200 
     ${resp}=  List Favourite Provider 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

     
       

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Upload {
  
  struct Access{
     address user; 
     bool access; //true or false
  }
  //here we will store all the image url got from ipfs network of perticular users in below array
  //this array will be dynamic as user can store multiple images
  mapping(address=>string[]) value;

 // this will check wheter user have owenership to access the image 
  mapping(address=>mapping(address=>bool)) ownership;

  //this array will conatain which access user info as which user can access the image 
  mapping(address=>Access[]) accessList;
  //this will be used to store previous state of user as we are not using any server 
  mapping(address=>mapping(address=>bool)) previousData;

//using this add function user can store its images on pinata 

  function add(address _user,string memory url) external {
      value[_user].push(url);
  }

  //this function will allow whether access is given or not
  //msgsender will be owner of image and user will be one with image is shared

  //to solve this user getting two access we will main previousdata to check wheteher user have access or not  
  function allow(address user) external {//def
      ownership[msg.sender][user]=true; 
      if(previousData[msg.sender][user]){
         for(uint i=0;i<accessList[msg.sender].length;i++){
             if(accessList[msg.sender][i].user==user){
                  accessList[msg.sender][i].access=true; 
             }
         }
      }else{
          accessList[msg.sender].push(Access(user,true));  
          previousData[msg.sender][user]=true;  
      }
    
  }

  /*if we remove access of any user(false) in acccesslist array using disallow and 
  if in future we give access to that user (true) then array will contain same  
  user with different access and it will create an error */

  function disallow(address user) public{
      ownership[msg.sender][user]=false;
      for(uint i=0;i<accessList[msg.sender].length;i++){
          if(accessList[msg.sender][i].user==user){ 
              accessList[msg.sender][i].access=false;  
          }
      }
  }
//this function is used to display image to user
  function display(address _user) external view returns(string[] memory){
      require(_user==msg.sender || ownership[_user][msg.sender],"You don't have access");
      return value[_user];
  }
//this function is used to fetch the arraycontaing which user we have shared access of our data
  function shareAccess() public view returns(Access[] memory){
      return accessList[msg.sender];
  }
}
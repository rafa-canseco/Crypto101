// SPDX-License Identifier:MIT
pragma solidity 0.8.12;

contract Casino{
    mapping (address => uint256) public gameWeiValues;
    mapping (address => uint256) public blockHashesToBeUsed;
    mapping (address => uint256) public Players;

        enum STAGE {jugador1, jugador2, playGame }

        STAGE public stage;

        function jugador1() external{
            require(STAGE == stage.jugador1);
            Players[msg.sender];
            stage = stage.jugador2;

        }

        function jugador2() external{
            require(STAGE == stage.jugador2);
            Players[msg.sender];
            stage = stage.playGame;
        }


    function playGame() external payable {
        require(STAGE == stage.playGame);
       


        if (blockHashesToBeUsed[msg.sender] == 0){
            blockHashesToBeUsed[msg.sender] = block.number +2;
            gameWeiValues[msg.value] = msg.value;
            
            return;
        
    

        }
        require(msg.value == 0,"lottery:finish current game before starting a new one");
        require(blockhash(blockHashesToBeUsed[msg.sender]) != 0,
        "lottery = not mined yet");
      

        uint256 randomNumber =    uint256(blockhash(blockHashesToBeUsed[msg.sender]));

        if( randomNumber != 0 && randomNumber % 2 == 0){
            uint256 winningAmount = gameWeiValues[msg.sender] * 2;
            (bool success,) = msg.sender.call{value : winningAmount}("");
            require(success,"lottery :winning payout failed");

        }

        blockHashesToBeUsed[msg.sender] = 0;
        gameWeiValues[msg.sender] = 0;
        Players[msg.sender] = 0;
    }


}

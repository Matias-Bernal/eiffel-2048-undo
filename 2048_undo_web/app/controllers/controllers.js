/*#######################################################################

#######################################################################*/

undo.controller('GameController', ['$scope','$http', function ($scope,$http) {
    
    $scope.user = '';
    $scope.password= '';

    $scope.cell_1_1 = '';
    $scope.cell_1_2 = '';
    $scope.cell_1_3 = '';
    $scope.cell_1_4 = '';
    
    $scope.cell_2_1 = '';
    $scope.cell_2_2 = '';
    $scope.cell_2_3 = '';
    $scope.cell_2_4 = '';
    
    $scope.cell_3_1 = '';
    $scope.cell_3_2 = '';
    $scope.cell_3_3 = '';
    $scope.cell_3_4 = '';
    
    $scope.cell_4_1 = '';
    $scope.cell_4_2 = '';
    $scope.cell_4_3 = '';
    $scope.cell_4_4 = '';
    
    $scope.init = function(){
        //$scope.loadLoginMenu();
    };
    
    $scope.keyEvent = function(){   
        var $doc = angular.element(document);
        $doc.on('keydown', $scope.keyPress);
        $scope.$on('$destroy', function() {
            $doc.off('keydown', $scope.keyPress);
        });
    };
    
    $scope.updateBoard = function(obj){
        if((obj.board[0])[0] != 0) $scope.cell_1_1 = (obj.board[0])[0]; else $scope.cell_1_1 = '';
        if((obj.board[1])[0] != 0) $scope.cell_1_2 = (obj.board[1])[0]; else $scope.cell_1_2 = '';
        if((obj.board[2])[0] != 0) $scope.cell_1_3 = (obj.board[2])[0]; else $scope.cell_1_3 = '';
        if((obj.board[3])[0] != 0) $scope.cell_1_4 = (obj.board[3])[0]; else $scope.cell_1_4 = '';
        
        if((obj.board[0])[1] != 0) $scope.cell_2_1 = (obj.board[0])[1]; else $scope.cell_2_1 = '';
        if((obj.board[1])[1] != 0) $scope.cell_2_2 = (obj.board[1])[1]; else $scope.cell_2_2 = '';
        if((obj.board[2])[1] != 0) $scope.cell_2_3 = (obj.board[2])[1]; else $scope.cell_2_3 = '';
        if((obj.board[3])[1] != 0) $scope.cell_2_4 = (obj.board[3])[1]; else $scope.cell_2_4 = '';
        
        if((obj.board[0])[2] != 0) $scope.cell_3_1 = (obj.board[0])[2]; else $scope.cell_3_1 = '';
        if((obj.board[1])[2] != 0) $scope.cell_3_2 = (obj.board[1])[2]; else $scope.cell_3_2 = '';
        if((obj.board[2])[2] != 0) $scope.cell_3_3 = (obj.board[2])[2]; else $scope.cell_3_3 = '';
        if((obj.board[3])[2] != 0) $scope.cell_3_4 = (obj.board[3])[2]; else $scope.cell_3_4 = '';
        
        if((obj.board[0])[3] != 0) $scope.cell_4_1 = (obj.board[0])[3]; else $scope.cell_4_1 = '';
        if((obj.board[1])[3] != 0) $scope.cell_4_2 = (obj.board[1])[3]; else $scope.cell_4_2 = '';
        if((obj.board[2])[3] != 0) $scope.cell_4_3 = (obj.board[2])[3]; else $scope.cell_4_3 = '';
        if((obj.board[3])[3] != 0) $scope.cell_4_4 = (obj.board[3])[3]; else $scope.cell_4_4 = '';
        
        $scope.$apply();
    };
    
    $scope.loginUser = function (){
        alert('login')
        $.ajax({
            type : 'POST',
            url:'http://localhost:9999/',
            data:{login:"" , nickname:$scope.user, password:$scope.password },
            contentType:'json',
            headers: {
                Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            success: function(data, textStatus, jqXHR) {
                var obj = angular.fromJson(data);
                if(obj.status == 'error')
                    alert("Usuario y/o Contraseñas invalidas")
                if(obj.status == 'logged'){
                    $scope.loadGameMenu();
                    $scope.updateBoard(obj);
                    $scope.keyEvent();
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("Error: " +textStatus);
            }
        })
    };
    
    $scope.newUser = function (){
        $.ajax({
            type : 'POST',
            url:'http://localhost:9999/',
            data:{new_user:"" , nickname:$scope.user, password:$scope.password },
            contentType:'json',
            headers: {
                Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            success: function(data, textStatus, jqXHR) {
                var obj = angular.fromJson(data);
                if(obj.status == 'error')
                    alert("Usuario invalido")
                if(obj.status == 'logged'){
                   $scope.loadGameMenu();
                   $scope.keyEvent();
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("Error: " +textStatus);
            }
        })
    };
     
    $scope.saveGame = function (){
        $.ajax({
            type : 'POST',
            url:'http://localhost:9999/',
            data:{game:"" , save:"" },
            contentType:'json',
            headers: {
                Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            success: function(data, textStatus, jqXHR) {
                var obj = angular.fromJson(data);
                if(obj.status == 'saved'){
                    $scope.user = '';
                    $scope.password = '';
                    $scope.resetBoard();
                    $scope.loadLoginMenu();
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("Error: " +textStatus);
            }
        })
    };
    
    $scope.newGame = function (){
        $.ajax({
            type : 'POST',
            url:'http://localhost:9999/',
            data:{game:"" , new_game:"" },
            contentType:'json',
            headers: {
                Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            success: function(data, textStatus, jqXHR) {
                var obj = angular.fromJson(data);
                if(obj.status == 'new_game'){
                    $scope.loadGameMenu();
                    $scope.updateBoard(obj);
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("Error: " +textStatus);
            }
        })
    };
    
    $scope.exitGame = function (){
        $.ajax({
            type : 'POST',
            url:'http://localhost:9999/',
            data:{game:"" , exit:"" },
            contentType:'json',
            headers: {
                Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            success: function(data, textStatus, jqXHR) {
                var obj = angular.fromJson(data);
                if(obj.status == 'exit'){
                    $scope.user = '';
                    $scope.password = '';
                    $scope.resetBoard();
                    $scope.loadLoginMenu(); 
                    $scope.$digest();
                    
                    
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("Error: " +textStatus);
            }
        })
    };
    
    $scope.resetBoard = function(){
        $scope.cell_1_1 = '';
        $scope.cell_1_2 = '';
        $scope.cell_1_3 = '';
        $scope.cell_1_4 = '';
        $scope.cell_2_1 = '';
        $scope.cell_2_2 = '';
        $scope.cell_2_3 = '';
        $scope.cell_2_4 = '';
        $scope.cell_3_1 = '';
        $scope.cell_3_2 = '';
        $scope.cell_3_3 = '';
        $scope.cell_3_4 = '';
        $scope.cell_4_1 = '';
        $scope.cell_4_2 = '';
        $scope.cell_4_3 = '';
        $scope.cell_4_4 = '';
        
        $scope.$apply();    
    };
    
    $scope.move = function(direction){
       $.ajax({
            type : 'POST',
            url:'http://localhost:9999/',
            data:{game:"" , move:direction },
            contentType:'json',
            headers: {
                Accept : 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            success: function(data, textStatus, jqXHR) {
                var obj = angular.fromJson(data);
                if(obj.status == 'win'){
                    $scope.updateBoard(obj);
                    alert("You win");
                }
                if(obj.status == 'lose'){
                    $scope.updateBoard(obj);
                    alert("You lose");
                }
                if(obj.status == 'play'){
                    $scope.updateBoard(obj);
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("Error: " +textStatus);
            }
        })
    };
    
    $scope.loadGameMenu = function (){
        var newField= document.getElementById("dinamic_menu");
		newField.innerHTML=
            "<form class='form-signin' form action='/' method='POST' role='form' id='649512336'>"+
            "   <h1><span class='label label-default' align='center'> 2048 UNDO </span></h1><br>"+
            "   <input class='btn btn-lg btn-primary btn-block' type='button' id='btn_newgame' ng-click='$scope.newGame()' value='New Game'/>"+
            "   <input class='btn btn-lg btn-primary btn-block' type='button' id='btn_savegame' ng-click='$scope.saveGame()' value='Save Game & Exit'/>"+
            "   <input class='btn btn-lg btn-primary btn-block' type='button' id='btn_exit' ng-click='$scope.exitGame()' value='Exit'/>"+
            "</form>";
            var btn_newgame = document.getElementById('btn_newgame');
            btn_newgame.addEventListener('click',$scope.newGame);
            var btn_savegame = document.getElementById('btn_savegame');
            btn_savegame.addEventListener('click',$scope.saveGame);
            var btn_exit = document.getElementById('btn_exit');
            btn_exit.addEventListener('click',$scope.exitGame);
        
            $scope.$digest();
    };
    
    $scope.loadLoginMenu = function (){
        var newField= document.getElementById("dinamic_menu");
		newField.innerHTML=
            "<form class='form-signin' form action='/' method='POST' role='form' id='649512336'>"+
            "   <h1><span class='label label-default' align='center'> 2048 UNDO </span></h1><br>"+
            "   <input type='nickname' ng-model='user' id='tx_login' class='form-control' placeholder='Nickname' required='' autofocus=''>"+
            "   <input type='password' ng-model='password' id='tx_pass' class='form-control' placeholder='Password' required='' autofocus=''>"+
            "   <input class='btn btn-lg btn-primary btn-block' type='button' id='btn_login' ng-click='$scope.loginUser()' value='Login User'/>"+
            "   <input class='btn btn-lg btn-primary btn-block' type='button' id='btn_newuser' ng-click='$scope.newUser()' value='New User'/>"+
            "</form>";
        
            var btn_login = document.getElementById('btn_login');
            btn_login.addEventListener('click',$scope.loginUser);
            var btn_newuser = document.getElementById('btn_newuser');
            btn_newuser.addEventListener('click',$scope.newUser);
        
            $scope.$digest();     
    };
    
    
    $scope.keyPress = function(keyEvent){
        var direction = getDirection(keyEvent.which);
        if (direction!=null) {
            $scope.move(direction);
        };
    };
    
    function getDirection(keyCode){
        var result;
        switch(keyCode){
            case 87:
            result = "up";
            break;
            case 83:
            result = "down"
            break;
            case 68:
            result = "right"
            break;
            case 65:
            result = "left"
            break;
            case 90:
            result = "undo"
            break;
            default:
            result = null;
        }
        return result;
    };
    
}]);
'use strict';

var myApp = angular

    .module('2048Undo', [])

    .controller('GameController', ['$scope', function ($scope) {
        
        $scope.user = '';
        $scope.password = '';
    
        $scope.resetear = function (){
            $scope.user = '';
            $scope.password = '';
        };
    }]);

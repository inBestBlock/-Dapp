import React, { Component } from "react";
import getWeb3 from "./utils/getWeb3";
import ShopContract from "../build/contracts/Shop.json";

import "./App.css";

class App extends Component {
    constructor(props) {
        super(props);

        this.state = {
            shopIntance: null,
            myAccount: null,
            myMoney: 0,
            web3: null
        };
    }

    componentWillMount() {
        getWeb3
            .then(results => {
                this.setState({
                    web3: results.web3
                });

                this.instantiateContract();
                this.buyMoney();
                this.sellMoney();

            })
            .catch(() => {
                console.log("Error finding web3.");
            });
    }

    instantiateContract() {
        const contract = require("truffle-contract");
        const shop = contract(ShopContract);
        shop.setProvider(this.state.web3.currentProvider);
        this.state.web3.eth.getAccounts((error, accounts) => {
            if (!error) {
                shop.deployed().then(instance => {
                    this.setState({ shopInstance: instance, myAccount: accounts[0] });
                    this.updateMoney();
                });
            }
        });

    }

    buyMoney() {
        this.state.shopInstance.buyApple({
            from: this.state.myAccount,
            value: this.state.web3.toWei(10, "ether"),
            gas: 900000
        });
    }

    sellMoney() {
        this.state.shopInstance.sellMyApple(this.state.web3.toWei(10, "ether"), {
            from: this.state.myAccount,
            gas: 900000
        });
    }

    updateMoney() {
        this.state.shopInstance.getMyApples().then(result => {
            this.setState({ myMoney: result.toNumber() });
        });
    }

    render() {
        return (
            <div className="App">
                <h1>펀드 구매, 판매</h1>
                <p>구매 : 0.1%지분당 10eth </p>
                <button onClick={() => this.buyMoney()}>구매하기</button>
                <p>내가 가진 지분:({0.1 * this.state.myApples}%) </p>
                <button onClick={() => this.sellMoney()}>
                    판매하기 (판매 가격: {(10 * this.state.myApples) + (10 * this.state.myApples * 0.04)})
                </button>
            </div>
        );
    }
}

export default App;

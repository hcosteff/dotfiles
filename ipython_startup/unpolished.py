import datetime
import random
import colorama
from collections import defaultdict
from collections import namedtuple
import math
class mathhelpers:

    def calculate_years_of_bits_for_nano_events(single_event_latency_nanos, bits=64):
        max_allowed = 2**bits

        events_per_sec = (1000*1000*1000)/single_event_latency_nanos
        events_per_year = events_per_sec*3600*24*365
        years_before_overflow = max_allowed/events_per_year
        return years_before_overflow

    def compound_interest(initial_principal, interest_rate, periods):
        return initial_principal * (interest_rate ** periods)

    def monthly_investment_calc(num_years, monthly_invest, yearly_nominal_yield = 1.075, yearly_inflation = 1, tax_on_returns = 0.25, print_progress=False, start_sum=0):
        yearly_yield_inflation_adjusted = (yearly_nominal_yield - 1) + (yearly_inflation - 1) + 1
        monthly_adjusted = yearly_yield_inflation_adjusted**(12**-1)
        capital = start_sum
        returns = 0
        for i in range(num_years*12):
            returns += ((capital + returns) * (monthly_adjusted - 1))
            capital += monthly_invest

            if print_progress:
                width=5
                precision=2
                SPACER="\t\t"
                print(f"year={int(i/12)}{SPACER}capital={capital:{width}.{precision}f}{SPACER}returns={returns:{width}.{precision}f}{SPACER}owe_tax={returns*tax_on_returns:{width}.{precision}f}{SPACER}")

        res = [capital+returns, capital+returns - returns*tax_on_returns, capital]
        return namedtuple("MonthlyInvRes", "total after_tax input")(*[int(round(x, -1)) for x in res])

    def loan_investment_calc(num_years, loan_principle, yearly_nominal_yield = 1.075, interest_rate = 1.02, yearly_inflation = 1, tax_on_returns = 0.25, print_progress=False):
        yearly_yield_inflation_adjusted = (yearly_nominal_yield - 1) + (yearly_inflation - 1) + 1
        monthly_adjusted_yield = yearly_yield_inflation_adjusted**(12**-1)

        monthly_adjusted_interest = interest_rate**(12**-1)

        n = num_years * 12
        i = monthly_adjusted_interest-1
        d = (((1+i)**n) - 1) / (i*(1+i)**n)
        monthly_payment = loan_principle / d
        total_loan_price = monthly_payment*num_years*12


        monthly_payment_no_interest = loan_principle/(num_years*12)

        loan_remainder_to_pay = total_loan_price
        total_returns = 0
        total_interest = total_loan_price - loan_principle
        payment_on_loan = 0
        for i in range(num_years*12):
            money_invested = loan_principle + total_returns
            total_returns += (money_invested * (monthly_adjusted_yield - 1))
            loan_remainder_to_pay -= monthly_payment
            payment_on_loan += monthly_payment

            if print_progress:
                width=5
                precision=2
                SPACER="\t\t"
                print(f"year={int(i/12)}{SPACER}money_invested={int(money_invested)}{SPACER}loan_remainder_to_pay={loan_remainder_to_pay:{width}.{precision}f}{SPACER}total_returns={total_returns:{width}.{precision}f}{SPACER}owe_tax={(total_returns-total_interest)*tax_on_returns:{width}.{precision}f}{SPACER}")

        res = [loan_principle + total_returns, loan_principle + total_returns - total_interest - (total_returns-total_interest)*tax_on_returns, total_interest, total_returns, monthly_payment, monthly_payment*12*num_years, loan_principle]
        return namedtuple("LoanInvRes", "total after_tax, total_interest total_returns monthly_payment input principal")(*[int(round(x, -1)) for x in res])

    def diff_loan_save(num_years, monthly_payment, interest_rate):
        monthly_adjusted_interest = interest_rate**(12**-1)
        n = num_years * 12
        i = monthly_adjusted_interest-1
        d = (((1+i)**n) - 1) / (i*(1+i)**n)
        loan_principle = monthly_payment * d

        loan_res = mathhelpers.loan_investment_calc(num_years, loan_principle, interest_rate=interest_rate)
        save_res = mathhelpers.monthly_investment_calc(num_years, monthly_payment)
        return loan_res.after_tax - save_res.after_tax, loan_res, save_res

    def sim_balls_bins(n_bins, n_balls, return_bins=False):
        bins = defaultdict(int)
     
        for i in range(n_balls):
            if i % 1000000 == 0:
                print(i, n_balls, i/n_balls*100, "%")
            selected_bin = random.randint(0, n_bins - 1)
            bins[selected_bin] = bins[selected_bin] + 1

        
        if len(bins) < n_bins:
            minimum = 0
        else:
            minimum = min(bins)
        maximum = max(bins.values())
        res = namedtuple("ballsbinsres", "n_bins n_balls max min")(n_bins, n_balls, maximum, minimum)
        return (res, bins) if return_bins else res
    def sim_balls_bins_multi(n_bins, n_balls, n_iters, print_only_on_max_exceeding=None):
        n_exceed = 0
        for i in range(n_iters):
            res = mathhelpers.sim_balls_bins(n_bins, n_balls)
            if print_only_on_max_exceeding:
                if res.max > print_only_on_max_exceeding:
                    print(res)
                    n_exceed += 1
            else:
                print(res)
                n_exceed += 1
        return n_exceed

    def calculate_payouts(player_exits):
        positive_players = {k:v for k,v in player_exits.items() if v > 0}
        negative_players = {k:v for k,v in player_exits.items() if v < 0}

        unaccounted_payouts = sum(player_exits.values())
        if unaccounted_payouts > 0:
            error = f"Extra chips in game - we have {abs(unaccounted_payouts)} more chips in play than were bought-in."
        else:
            error = f"Missing chips in game - we have {abs(unaccounted_payouts)} fewer chips in play than were bought-in."

        assert unaccounted_payouts == 0, f"{error} (sum of all exits should be zero)"

        positive_players = {k:v for k,v in player_exits.items() if v > 0}
        negative_players = {k:v for k,v in player_exits.items() if v < 0}

        payments = []
        while positive_players or negative_players:
            payee = random.choice(list(positive_players.keys()))
            payer = random.choice(list(negative_players.keys()))
            
            payment_amount = min(abs(positive_players[payee]), abs(negative_players[payer]))
            payments.append(f"{payer} -> {payee} {payment_amount}")

            positive_players[payee] -= payment_amount
            negative_players[payer] += payment_amount
            if positive_players[payee] == 0:
                del positive_players[payee]
            if negative_players[payer] == 0:
                del negative_players[payer]
        return payments

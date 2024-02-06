##define function validate
validate <- function(r, s, m) {

    #COMPILE DATA
    rk.eval <- r;
    rk.eval$method <- 'reskrig';
    rk.eval$text <- 'Digitala åkermarkskartan (DSMS) anpassad med lokala prover!'
    sk.eval <- s;
    sk.eval$method <- 'stdkrig';
    sk.eval$text <- 'Karta baserad enbart på lokala prover!'
    mp.eval <- m;
    mp.eval$method <- 'dsms';
    mp.eval$text <- 'Digitala åkermarkskartan (DSMS)'
    valstat <- rbind(rk.eval, sk.eval, mp.eval)
    MAE <- valstat[valstat$measure == 'MAE',]
    MAE$rank <- rank(MAE$value)

    #CREATE TEXTS
    best.method.text <- MAE[MAE$rank == 1, 'text']
    best.method <- MAE[MAE$rank == 1, 'method']

    #RETURN OUTPUT
    return(list(valstat, best.method.text, best.method))
}

###############################
#### MCELIECE CRYPTOSYSTEM ####
###############################

##.... configuration ....##


N = 31  # "length" -- the length of the code
K = 10
CODE = "bch"
#MENS = matrix([[1,0,1,0,1,0,0,1,0,1,1]])
MENS = matrix([[1,0,1,0,1,0,0,1,0,1]])
#MENS = matrix([[0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0],[0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0],[0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0],[1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0],[1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1 ,0 ,1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1],[1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],[0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0],[1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1],[0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1],[0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0]]).transpose()
#.........................#


"""
## GENERATE MATRIX S ##
    random  k x k binary non-singular matrix  S
"""
def genS(k):
    Sp = MatrixSpace(GF(2),k,k)
    M = Sp.random_element()
    while( not M.is_invertible() ):
        M = Sp.random_element()
    return M

"""
## GENERATE MATRIX P ##
    random  n x n binary permutation matrix  S
"""
def genP(n):
    Sp = MatrixSpace(GF(2),n,n)
    one = MatrixSpace(GF(2),1,1).matrix(1)
    M = Sp.matrix(0)
    not_used =  range(n) 
    for i in range(n):
        rand = randint(0,len(not_used)-1 )
        M.set_block(i,not_used[rand],one)
        not_used.remove(not_used[rand])
    return M

"""
## REED SOLOMON CODE ##

    INPUT:

       * "length" -- the length of the code

       * "designed_distance" -- the designed minimum distance of the
         code
"""
def Reed_solomon(n,k):
    return codes.GeneralizedReedSolomonCode(GF(59).list()[:n], k)
"""
## BCH CODE ##

    INPUT:

       * "length" -- the length of the code

       * "designed_distance" -- the designed minimum distance of the
         code
"""
def BCH(n,k):
    return codes.BCHCode(n, k,GF(2))

"""
## GOPPA CODE ##

    INPUT:

       * "length" -- the length of the code

       * "designed_distance" -- the designed minimum distance of the
         code
"""
def Goppa(n,k):
    return None

"""
## HAMMING CODE ##

    INPUT:

       * "length" -- the length of the code
"""
def Hamming(n,k):
    return codes.HammingCode(GF(2), n)

"""
## KEY GENERATION ##

    INPUT:

       * "length" -- the length of the code

       * "designed_distance" -- the designed minimum distance of the
         code
         
       * "code" -- binary (n,k)-linear code  C capable of correcting  t errors

    RETURN:

       * "code" -- binary (n,k)-linear code  C capable of correcting  t errors
    
       * "public key " -- (G_,t)

       * "private key " -- (S,G,P)
"""
def geneKey(n,k,code="bch"):
    """
    C = {
        "red_solomon" : Reed_solomon(n,k),
        "bch" : BCH(n,k),
        "goppa" : Goppa(n,k),
        "hamming" : Hamming(n,k)
        }[code]
    """
    C  = BCH(n,k)
    t  = (C.minimum_distance() - 1) // 2 
    print('t', t)
    k  = C.dimension()
    S  = genS(k)
    P  = genP(n)
    G  = C.generator_matrix()
    G_ = S*G*P
    print(G_)
    return [C,(G_,t),(S,G,P)]
    

"""

## GENERATE VECTOR Z ##
    random n-bit vector z containing exactly t ones (a vector of length  n and weight  t)

    INPUT:

       * "length" -- the length of the code

       * "t" -- number of correctable errors
"""

def genZ(n,t):
    z = [0 for _ in range(n-t)]
    l = n-t
    while l < n:
        z.insert(randint(0,l), 1)
        l += 1
    return matrix([z])

"""
## MESSAGE ENCRYPTION ##

    INPUT:

       * "code" -- binary (n,k)-linear code  C capable of correcting  t errors

       * "public key " -- (G_,t)

       * "message " -- 

    RETURN:

       * "message " -- 

"""
def encryption(C, pubKey, mens):
    G_ , t = pubKey
    print('t', t)
    m = mens
    print(m)
    print(G_)
    c_ = m*G_
    z = genZ(31,t)
    print('z_', z)
    return c_ + z
    

"""
## MESSAGE DECRYPTION ##

    INPUT:

       * "code" -- binary (n,k)-linear code  C capable of correcting  t errors

       * "private key " -- (S,G,P)

       * "message " -- 

    RETURN:

       * "message " -- 

"""
def decryption(C, privKey, mens):
    S,G,P = privKey
    P_ = P.inverse()
    c_ = mens*P_
    print('c_', c_)
#print('M_', matrix(C.encode(vector(mens))))
#print('M_', C.encode(c_))
    print("vector c_ 0 ->",vector(c_[0]))
#m = C.decode_to_message(GF(2),vector(c_[0]))
    m = C.decode_to_message(GF(2),vector((1,1,0,1,1,0,1,0,1,1)))
    print('m', m)
    print("chegou")
    return m*S.inverse()


def main():
    code, pubKey, privKey = geneKey(N,K,CODE)
    mens_ = encryption(code,pubKey,MENS)
    #Proof of message decryption
    if(MENS == decryption(code,privKey,mens_)):
        print(" MENS = decryption( encryption (mens) ) ")
    else:
        print("----Error-----")
        print(" MENS != decryption( encryption (mens) ) ")




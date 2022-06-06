set -e
if [ -f ../powersOfTau28_hez_final_08.ptau ]; then
    echo "powersOfTau28_hez_final_08.ptau already exists. Skipping."
else
    pushd ../
    echo 'Downloading powersOfTau28_hez_final_08.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_08.ptau
    popd
fi

echo "compiling circom"
circom bad_force_equal_if_enabled.circom --r1cs --wasm --sym

cd bad_force_equal_if_enabled_js;
node generate_witness.js bad_force_equal_if_enabled.wasm ../input.json ../witness.wtns
cd ..
#
snarkjs groth16 setup bad_force_equal_if_enabled.r1cs ../powersOfTau28_hez_final_16.ptau bad_force_equal_if_enabled_0000.zkey
echo "test" | snarkjs zkey contribute bad_force_equal_if_enabled_0000.zkey bad_force_equal_if_enabled_final.zkey --name="1st Contributor Name" -v
snarkjs zkey verify bad_force_equal_if_enabled.r1cs ../powersOfTau28_hez_final_16.ptau bad_force_equal_if_enabled_final.zkey
snarkjs zkey export verificationkey bad_force_equal_if_enabled_final.zkey verification_key.json
snarkjs groth16 prove bad_force_equal_if_enabled_final.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json

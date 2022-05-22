.data
	array: .space 10
.text
init:
addi 	$s1,$0,4
addi 	$t0,$0,0
sw 	    $s1,array($t0)
addi 	$s1,$0,5
addi 	$t0,$t0,4
sw 	    $s1,array($t0)
addi 	$s1,$0,3
addi 	$t0,$t0,4
sw 	    $s1,array($t0)
addi 	$s1,$0,2
addi 	$t0,$t0,4
sw 	    $s1,array($t0)
addi 	$s1,$0,1
addi 	$t0,$t0,4
sw 	    $s1,array($t0)

initfor1:
addi 	$s2,$0,0
addi    $t8,$0,1
addi    $t9,$0,4
addi	$s5,$0,16

startfor1:
beq	$s2,$s5,end
initfor2:
addi 	$s3,$0,0
addi	$s6,$0,16
subu	$s6,$s6,$s2
startfor2:
beq	$s3,$s6,endfor1
lw      $t1,array($s3)
addi	$s4,$s3,4
lw      $t2,array($s4)

if:
slt	$t3,$t2,$t1
beq	$t3,$0,endfor2
swap:
sw	$t1,array($s4)
sw	$t2,array($s3)

endfor2:
addi	$s3,$s3,4
j	startfor2
endfor1:
addi	$s2,$s2,4
j	startfor1

end:
nop



function reuleaux(az, theta) = let (
    // A torus with Reuleaux Triangle cross-section: 
    // See https://en.wikipedia.org/wiki/Reuleaux_triangle.
    //
    //Args:
    //    az: azimuth: angle around major axis.
    //    theta: [0,360] angle around minor axis.
    use_reuleaux = true,  // true for rounded triangle, false for normal triangle
    major_radius = 14.0, // mm
    minor_radius = 5.0, // mm
    z_scale = 1, // ratio of z height to minor axis diameter
    twists = 1/3, //number of times the cross-section twists as it goes round the ring
    
    mod_theta = theta % 120 - 60,
    cos_theta = cos(mod_theta),
    twist = az*twists,
    // Use Polar equation of a circle from https://en.wikipedia.org/wiki/Polar_coordinate_system#Circle
    // R=1, r0=1/sqrt(3) (2/3 height of unit sided equilateral triangle, offset of centre of reuleaux arc)
    r_reuleaux = (sqrt(4.0/3.0*cos_theta*cos_theta + 8.0/3.0) - 2.0/sqrt(3.0)*cos_theta)/2.0,
    degrees = (twist+30)%120-30,
    //echo(twist, degrees),
    r0_reuleaux = (degrees<30) ?
        1-cos(degrees)/sqrt(3.0)
        : cos(degrees-60)/sqrt(3.0),
    // or triange cross-section:
    r_triangle = 1.0/cos_theta/6.0,
    r0_triangle = 0,

    r = use_reuleaux ? r_reuleaux : r_triangle,
    r0 = use_reuleaux ? r0_reuleaux : r0_triangle,
    
    theta2 = theta + twist,  //twist it!
    reuleaux_factor = r * cos(theta2) - r0 - 0.5,
    //based on parametric equation of a torus
    full_radius = major_radius + minor_radius * reuleaux_factor,
    x = sin(-az) * full_radius,
    y = cos(-az) * full_radius,
    z = r * sin(theta2) * minor_radius * z_scale
    ) 
    [x, y, z];
    

az_step = 3.6;
theta_step = 10;
if(true) {
    polyhedron(points = [
        for(az = [0:az_step:360-1], theta = [0:theta_step:360-1])
            each let(
                p0 = reuleaux(az, theta),
                p1 = reuleaux(az+az_step, theta),
                p2 = reuleaux(az+az_step, theta+theta_step),
                p3 = reuleaux(az, theta+theta_step)
            ) [p0, p1, p2, p3]
        ],
        
        faces =  [for (i = [0:360/az_step*120/theta_step *3]) each
                        [[i*4,i*4+1,i*4+2], [i*4+2,i*4+3,i*4]]
        ]
    );
}
else
{
    for(az=[0:36: 360]) {
        translate([0, 0, az/36])
        polygon(points = [
            for(theta = [0:theta_step:360-1])
                each let(
                    p0 = reuleaux(az, theta)
                ) [[p0[1], p0[2]]]  // pick y and z
            ]
        );
    }
}